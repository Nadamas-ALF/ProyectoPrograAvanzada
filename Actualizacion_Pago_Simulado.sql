/* ============================================================
   ACTUALIZACION: PAGO SIMULADO MAS REALISTA
   Agrega un dato de pago simulado (comprobante) capturado en el
   checkout segun el metodo de pago elegido (tarjeta, transferencia
   bancaria, SINPE Movil o efectivo contra entrega), y lo expone en
   la pantalla de confirmacion del pedido.

   Ejecutar sobre BD_LEN despues de BD_LN.sql,
   Administracion_RF11_RF14.sql y Catalogo_RF01_RF03_RF10.sql.

   Este script es idempotente (CREATE OR ALTER): se puede correr
   varias veces sin problema.
   ============================================================ */

USE BD_LEN;
GO

/* ============================================================
   SP_ConfirmarCompra
   Se agrega el parametro @DatoPagoSimulado, que reemplaza el
   comprobante generado automaticamente cuando el cliente
   proporciona un dato de pago simulado (ultimos digitos de
   tarjeta, referencia de transferencia o telefono de SINPE).
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConfirmarCompra
    @IdUsuario INT,
    @IdDireccion INT,
    @IdMetodoPago INT,
    @CostoEnvio DECIMAL(10,2),
    @DatoPagoSimulado NVARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        IF @CostoEnvio IS NULL OR @CostoEnvio < 0
        BEGIN
            SELECT
                CAST(0 AS BIT) AS Exitoso,
                N'El costo de envío no es válido.' AS Mensaje,
                CAST(NULL AS INT) AS IdPedido,
                CAST(NULL AS NVARCHAR(50)) AS NumeroFactura;
            RETURN;
        END;

        DECLARE @IdEstadoActivo INT;
        DECLARE @IdEstadoDisponible INT;
        DECLARE @IdEstadoPagado INT;

        SELECT @IdEstadoActivo = id_estado
        FROM dbo.TB_estado
        WHERE nombre_estado = N'Activo';

        SELECT @IdEstadoDisponible = id_estado
        FROM dbo.TB_estado
        WHERE nombre_estado = N'Disponible';

        SELECT @IdEstadoPagado = id_estado
        FROM dbo.TB_estado
        WHERE nombre_estado = N'Pagado';

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.TB_direccion_envio
            WHERE id_direccion = @IdDireccion
              AND id_usuario = @IdUsuario
              AND id_estado = @IdEstadoActivo
        )
        BEGIN
            SELECT
                CAST(0 AS BIT) AS Exitoso,
                N'La dirección seleccionada no es válida.' AS Mensaje,
                CAST(NULL AS INT) AS IdPedido,
                CAST(NULL AS NVARCHAR(50)) AS NumeroFactura;
            RETURN;
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM dbo.TB_metodo_pago
            WHERE id_metodo_pago = @IdMetodoPago
              AND id_estado = @IdEstadoActivo
        )
        BEGIN
            SELECT
                CAST(0 AS BIT) AS Exitoso,
                N'El método de pago seleccionado no es válido.' AS Mensaje,
                CAST(NULL AS INT) AS IdPedido,
                CAST(NULL AS NVARCHAR(50)) AS NumeroFactura;
            RETURN;
        END;

        DECLARE @IdCarrito INT;

        SELECT TOP (1) @IdCarrito = id_carrito
        FROM dbo.TB_carrito
        WHERE id_usuario = @IdUsuario
          AND id_estado = @IdEstadoActivo
        ORDER BY id_carrito;

        IF @IdCarrito IS NULL
           OR NOT EXISTS
           (
               SELECT 1
               FROM dbo.TB_detalle_carrito
               WHERE id_carrito = @IdCarrito
           )
        BEGIN
            SELECT
                CAST(0 AS BIT) AS Exitoso,
                N'El carrito está vacío.' AS Mensaje,
                CAST(NULL AS INT) AS IdPedido,
                CAST(NULL AS NVARCHAR(50)) AS NumeroFactura;
            RETURN;
        END;

        BEGIN TRANSACTION;

        /* Bloqueo de las filas de producto del carrito y
           revalidación final de stock y disponibilidad. */
        DECLARE @Faltantes INT;

        SELECT @Faltantes = COUNT(*)
        FROM dbo.TB_detalle_carrito AS DC
        INNER JOIN dbo.TB_producto AS P WITH (UPDLOCK, ROWLOCK, HOLDLOCK)
            ON P.id_producto = DC.id_producto
        WHERE DC.id_carrito = @IdCarrito
          AND (P.stock < DC.cantidad OR P.id_estado <> @IdEstadoDisponible);

        IF @Faltantes > 0
        BEGIN
            ROLLBACK TRANSACTION;

            SELECT
                CAST(0 AS BIT) AS Exitoso,
                N'Algunos productos ya no cuentan con stock suficiente. Por favor revise su carrito.' AS Mensaje,
                CAST(NULL AS INT) AS IdPedido,
                CAST(NULL AS NVARCHAR(50)) AS NumeroFactura;
            RETURN;
        END;

        DECLARE @Subtotal DECIMAL(10,2);

        SELECT @Subtotal = CONVERT(DECIMAL(10,2), SUM(P.precio * DC.cantidad))
        FROM dbo.TB_detalle_carrito AS DC
        INNER JOIN dbo.TB_producto AS P
            ON P.id_producto = DC.id_producto
        WHERE DC.id_carrito = @IdCarrito;

        DECLARE @Total DECIMAL(10,2) = @Subtotal + @CostoEnvio;

        INSERT INTO dbo.TB_pedido
        (
            id_usuario,
            id_direccion,
            subtotal,
            costo_envio,
            total,
            id_estado
        )
        VALUES
        (
            @IdUsuario,
            @IdDireccion,
            @Subtotal,
            @CostoEnvio,
            @Total,
            @IdEstadoPagado
        );

        DECLARE @IdPedido INT = SCOPE_IDENTITY();

        INSERT INTO dbo.TB_detalle_pedido
        (
            id_pedido,
            id_producto,
            cantidad,
            precio_unitario,
            subtotal_linea
        )
        SELECT
            @IdPedido,
            DC.id_producto,
            DC.cantidad,
            P.precio,
            CONVERT(DECIMAL(10,2), P.precio * DC.cantidad)
        FROM dbo.TB_detalle_carrito AS DC
        INNER JOIN dbo.TB_producto AS P
            ON P.id_producto = DC.id_producto
        WHERE DC.id_carrito = @IdCarrito;

        UPDATE P
        SET P.stock = P.stock - DC.cantidad
        FROM dbo.TB_producto AS P
        INNER JOIN dbo.TB_detalle_carrito AS DC
            ON DC.id_producto = P.id_producto
        WHERE DC.id_carrito = @IdCarrito;

        DECLARE @NumeroFactura NVARCHAR(50) =
            N'FAC-' + RIGHT(N'000000' + CAST(@IdPedido AS NVARCHAR(10)), 6);

        /*
         * Pago simulado: si el cliente proporciono un dato de pago
         * (tarjeta/transferencia/SINPE) se usa como comprobante;
         * si no, se genera uno automatico como antes.
         */
        DECLARE @Comprobante NVARCHAR(255) =
            ISNULL(
                NULLIF(LTRIM(RTRIM(@DatoPagoSimulado)), N''),
                N'SIM-' + RIGHT(N'000000' + CAST(@IdPedido AS NVARCHAR(10)), 6)
            );

        INSERT INTO dbo.TB_pago
        (
            id_pedido,
            id_metodo_pago,
            monto,
            comprobante,
            id_estado
        )
        VALUES
        (
            @IdPedido,
            @IdMetodoPago,
            @Total,
            @Comprobante,
            @IdEstadoPagado
        );

        INSERT INTO dbo.TB_factura
        (
            id_pedido,
            numero_factura,
            subtotal,
            costo_envio,
            total,
            id_estado
        )
        VALUES
        (
            @IdPedido,
            @NumeroFactura,
            @Subtotal,
            @CostoEnvio,
            @Total,
            @IdEstadoPagado
        );

        /* El carrito queda vacío pero activo para reutilizarse. */
        DELETE FROM dbo.TB_detalle_carrito
        WHERE id_carrito = @IdCarrito;

        COMMIT TRANSACTION;

        SELECT
            CAST(1 AS BIT) AS Exitoso,
            N'La compra fue registrada correctamente.' AS Mensaje,
            @IdPedido AS IdPedido,
            @NumeroFactura AS NumeroFactura;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        DECLARE @MensajeError NVARCHAR(MAX) = ERROR_MESSAGE();
        DECLARE @LineaError INT = ERROR_LINE();

        EXEC dbo.SP_RegistrarError
            @Origen = N'Base de datos',
            @Metodo = N'SP_ConfirmarCompra',
            @MensajeError = @MensajeError,
            @LineaError = @LineaError;

        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No fue posible completar la compra. Por favor intente de nuevo.' AS Mensaje,
            CAST(NULL AS INT) AS IdPedido,
            CAST(NULL AS NVARCHAR(50)) AS NumeroFactura;
    END CATCH;
END;
GO

/* ============================================================
   SP_ConsultarConfirmacionPedido
   Se agrega la columna ComprobantePago (dato de pago simulado)
   para mostrarla en la pantalla de confirmación del pedido.
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarConfirmacionPedido
    @IdPedido INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PE.id_pedido AS IdPedido,
        F.numero_factura AS NumeroFactura,
        PE.fecha_pedido AS FechaPedido,
        PE.subtotal AS Subtotal,
        PE.costo_envio AS CostoEnvio,
        PE.total AS Total,
        E.nombre_estado AS NombreEstado,
        CASE E.nombre_estado
            WHEN N'Pagado' THEN N'Comprada'
            WHEN N'En preparación' THEN N'En camino'
            WHEN N'Entregado' THEN N'Recibido'
            ELSE E.nombre_estado
        END AS EstadoVisible,
        MP.nombre_metodo AS NombreMetodoPago,
        PG.comprobante AS ComprobantePago,
        DE.nombre_destinatario AS NombreDestinatario,
        DE.direccion_exacta AS DireccionExacta,
        DI.nombre_distrito AS NombreDistrito,
        CA.nombre_canton AS NombreCanton,
        PR.nombre_provincia AS NombreProvincia,
        P.id_producto AS IdProducto,
        P.nombre_producto AS NombreProducto,
        DP.cantidad AS Cantidad,
        DP.precio_unitario AS PrecioUnitario,
        DP.subtotal_linea AS SubtotalLinea,
        IMG.ruta_imagen AS RutaImagen
    FROM dbo.TB_pedido AS PE
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = PE.id_estado
    INNER JOIN dbo.TB_detalle_pedido AS DP
        ON DP.id_pedido = PE.id_pedido
    INNER JOIN dbo.TB_producto AS P
        ON P.id_producto = DP.id_producto
    INNER JOIN dbo.TB_direccion_envio AS DE
        ON DE.id_direccion = PE.id_direccion
    INNER JOIN dbo.TB_distrito AS DI
        ON DI.id_distrito = DE.id_distrito
    INNER JOIN dbo.TB_canton AS CA
        ON CA.id_canton = DI.id_canton
    INNER JOIN dbo.TB_provincia AS PR
        ON PR.id_provincia = CA.id_provincia
    LEFT JOIN dbo.TB_factura AS F
        ON F.id_pedido = PE.id_pedido
    LEFT JOIN dbo.TB_pago AS PG
        ON PG.id_pedido = PE.id_pedido
    LEFT JOIN dbo.TB_metodo_pago AS MP
        ON MP.id_metodo_pago = PG.id_metodo_pago
    LEFT JOIN dbo.TB_imagen_producto AS IMG
        ON IMG.id_producto = P.id_producto
       AND IMG.es_principal = 1
    WHERE PE.id_pedido = @IdPedido
      AND PE.id_usuario = @IdUsuario
    ORDER BY P.nombre_producto;
END;
GO
