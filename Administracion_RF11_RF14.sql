/* ============================================================
   MODULO DE ADMINISTRACION (Maria)
   RF-11 Gestion de productos
   RF-12 Gestion de inventario
   RF-13 Gestion de pedidos
   RF-14 Reportes de ventas
   Ejecutar sobre BD_LEN despues de BD_LN.sql
   ============================================================ */

USE BD_LEN;
GO

/* Columna para registrar el motivo de cancelacion (RF-13, escenario 3) */
IF COL_LENGTH('dbo.TB_pedido', 'motivo_cancelacion') IS NULL
BEGIN
    ALTER TABLE dbo.TB_pedido
    ADD motivo_cancelacion NVARCHAR(255) NULL;
END;
GO

/* ============================================================
   CATEGORIAS (apoyo a RF-11)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarCategorias
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.id_categoria      AS IdCategoria,
        C.nombre_categoria  AS NombreCategoria,
        C.descripcion       AS Descripcion,
        C.id_estado         AS IdEstado,
        E.nombre_estado     AS NombreEstado,
        (
            SELECT COUNT(*)
            FROM dbo.TB_producto AS P
            WHERE P.id_categoria = C.id_categoria
        ) AS CantidadProductos
    FROM dbo.TB_categoria AS C
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = C.id_estado
    ORDER BY C.nombre_categoria;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarCategoriasActivas
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoActivo INT;

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    SELECT
        C.id_categoria     AS IdCategoria,
        C.nombre_categoria AS NombreCategoria
    FROM dbo.TB_categoria AS C
    WHERE C.id_estado = @IdEstadoActivo
    ORDER BY C.nombre_categoria;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_InsertarCategoria
    @NombreCategoria NVARCHAR(100),
    @Descripcion NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM dbo.TB_categoria
        WHERE nombre_categoria = @NombreCategoria
    )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'Ya existe una categoría con ese nombre.' AS Mensaje,
            CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    DECLARE @IdEstadoActivo INT;

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    INSERT INTO dbo.TB_categoria (nombre_categoria, descripcion, id_estado)
    VALUES (@NombreCategoria, @Descripcion, @IdEstadoActivo);

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'Categoría creada correctamente.' AS Mensaje,
        CAST(SCOPE_IDENTITY() AS INT) AS IdGenerado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ActualizarCategoria
    @IdCategoria INT,
    @NombreCategoria NVARCHAR(100),
    @Descripcion NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.TB_categoria WHERE id_categoria = @IdCategoria
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'La categoría no existe.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM dbo.TB_categoria
        WHERE nombre_categoria = @NombreCategoria
          AND id_categoria <> @IdCategoria
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'Ya existe otra categoría con ese nombre.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    UPDATE dbo.TB_categoria
    SET nombre_categoria = @NombreCategoria,
        descripcion = @Descripcion
    WHERE id_categoria = @IdCategoria;

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Categoría actualizada correctamente.' AS Mensaje,
           @IdCategoria AS IdGenerado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_CambiarEstadoCategoria
    @IdCategoria INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoActivo INT, @IdEstadoInactivo INT, @IdEstadoActual INT;

    SELECT @IdEstadoActivo = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Activo';
    SELECT @IdEstadoInactivo = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Inactivo';

    SELECT @IdEstadoActual = id_estado
    FROM dbo.TB_categoria
    WHERE id_categoria = @IdCategoria;

    IF @IdEstadoActual IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'La categoría no existe.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    /* No permitir desactivar si tiene productos disponibles */
    IF @IdEstadoActual = @IdEstadoActivo
       AND EXISTS (
           SELECT 1
           FROM dbo.TB_producto AS P
           INNER JOIN dbo.TB_estado AS E ON E.id_estado = P.id_estado
           WHERE P.id_categoria = @IdCategoria
             AND E.nombre_estado IN (N'Disponible', N'Agotado')
       )
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'No es posible desactivar la categoría porque tiene productos activos asociados.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    UPDATE dbo.TB_categoria
    SET id_estado = CASE
                        WHEN @IdEstadoActual = @IdEstadoActivo THEN @IdEstadoInactivo
                        ELSE @IdEstadoActivo
                    END
    WHERE id_categoria = @IdCategoria;

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Estado de la categoría actualizado.' AS Mensaje,
           @IdCategoria AS IdGenerado;
END;
GO

/* ============================================================
   RF-11: PRODUCTOS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarProductos
    @Busqueda NVARCHAR(150) = NULL,
    @IdCategoria INT = NULL,
    @Pagina INT = 1,
    @TamanoPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @Pagina IS NULL OR @Pagina < 1 SET @Pagina = 1;
    IF @TamanoPagina IS NULL OR @TamanoPagina < 1 SET @TamanoPagina = 10;

    SELECT
        P.id_producto       AS IdProducto,
        P.nombre_producto   AS NombreProducto,
        P.precio            AS Precio,
        P.stock             AS Stock,
        P.es_pieza_unica    AS EsPiezaUnica,
        P.destacado         AS Destacado,
        P.id_categoria      AS IdCategoria,
        C.nombre_categoria  AS NombreCategoria,
        P.id_estado         AS IdEstado,
        E.nombre_estado     AS NombreEstado,
        P.fecha_creacion    AS FechaCreacion,
        (
            SELECT TOP 1 I.ruta_imagen
            FROM dbo.TB_imagen_producto AS I
            INNER JOIN dbo.TB_estado AS EI ON EI.id_estado = I.id_estado
            WHERE I.id_producto = P.id_producto
              AND EI.nombre_estado = N'Activo'
            ORDER BY I.es_principal DESC, I.id_imagen
        ) AS RutaImagen,
        COUNT(*) OVER () AS TotalFilas
    FROM dbo.TB_producto AS P
    INNER JOIN dbo.TB_categoria AS C ON C.id_categoria = P.id_categoria
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = P.id_estado
    WHERE (@Busqueda IS NULL OR @Busqueda = N''
           OR P.nombre_producto LIKE N'%' + @Busqueda + N'%')
      AND (@IdCategoria IS NULL OR P.id_categoria = @IdCategoria)
    ORDER BY P.fecha_creacion DESC, P.id_producto DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarProductoPorId
    @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.id_producto       AS IdProducto,
        P.nombre_producto   AS NombreProducto,
        P.descripcion       AS Descripcion,
        P.precio            AS Precio,
        P.stock             AS Stock,
        P.es_pieza_unica    AS EsPiezaUnica,
        P.destacado         AS Destacado,
        P.id_categoria      AS IdCategoria,
        P.id_estado         AS IdEstado,
        E.nombre_estado     AS NombreEstado
    FROM dbo.TB_producto AS P
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = P.id_estado
    WHERE P.id_producto = @IdProducto;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_InsertarProducto
    @NombreProducto NVARCHAR(150),
    @Descripcion NVARCHAR(MAX) = NULL,
    @Precio DECIMAL(10,2),
    @Stock INT,
    @EsPiezaUnica BIT,
    @Destacado BIT,
    @IdCategoria INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Precio IS NULL OR @Precio < 0
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El precio debe ser mayor o igual a cero.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    IF @Stock IS NULL OR @Stock < 0
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El stock debe ser mayor o igual a cero.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    IF @EsPiezaUnica = 1 AND @Stock > 1
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'Una pieza única no puede tener stock mayor a 1.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.TB_categoria AS C
        INNER JOIN dbo.TB_estado AS E ON E.id_estado = C.id_estado
        WHERE C.id_categoria = @IdCategoria
          AND E.nombre_estado = N'Activo'
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'La categoría seleccionada no es válida.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    DECLARE @IdEstadoInicial INT;

    SELECT @IdEstadoInicial = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = CASE WHEN @Stock > 0 THEN N'Disponible' ELSE N'Agotado' END;

    INSERT INTO dbo.TB_producto
        (nombre_producto, descripcion, precio, stock,
         es_pieza_unica, destacado, id_categoria, id_estado)
    VALUES
        (@NombreProducto, @Descripcion, @Precio, @Stock,
         @EsPiezaUnica, @Destacado, @IdCategoria, @IdEstadoInicial);

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Producto creado correctamente.' AS Mensaje,
           CAST(SCOPE_IDENTITY() AS INT) AS IdGenerado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ActualizarProducto
    @IdProducto INT,
    @NombreProducto NVARCHAR(150),
    @Descripcion NVARCHAR(MAX) = NULL,
    @Precio DECIMAL(10,2),
    @Stock INT,
    @EsPiezaUnica BIT,
    @Destacado BIT,
    @IdCategoria INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.TB_producto WHERE id_producto = @IdProducto)
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El producto no existe.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    IF @Precio IS NULL OR @Precio < 0 OR @Stock IS NULL OR @Stock < 0
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El precio y el stock deben ser mayores o iguales a cero.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    IF @EsPiezaUnica = 1 AND @Stock > 1
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'Una pieza única no puede tener stock mayor a 1.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    DECLARE @IdEstadoActual INT, @IdEstadoInactivo INT, @IdEstadoNuevo INT;

    SELECT @IdEstadoActual = id_estado
    FROM dbo.TB_producto
    WHERE id_producto = @IdProducto;

    SELECT @IdEstadoInactivo = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Inactivo';

    /* Si el producto está inactivo se mantiene inactivo;
       si está activo se recalcula Disponible/Agotado según stock */
    IF @IdEstadoActual = @IdEstadoInactivo
        SET @IdEstadoNuevo = @IdEstadoInactivo;
    ELSE
        SELECT @IdEstadoNuevo = id_estado
        FROM dbo.TB_estado
        WHERE nombre_estado = CASE WHEN @Stock > 0 THEN N'Disponible' ELSE N'Agotado' END;

    UPDATE dbo.TB_producto
    SET nombre_producto = @NombreProducto,
        descripcion = @Descripcion,
        precio = @Precio,
        stock = @Stock,
        es_pieza_unica = @EsPiezaUnica,
        destacado = @Destacado,
        id_categoria = @IdCategoria,
        id_estado = @IdEstadoNuevo
    WHERE id_producto = @IdProducto;

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Producto actualizado correctamente.' AS Mensaje,
           @IdProducto AS IdGenerado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_CambiarEstadoProducto
    @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoActual INT, @IdEstadoInactivo INT, @Stock INT, @IdEstadoNuevo INT;

    SELECT @IdEstadoActual = id_estado, @Stock = stock
    FROM dbo.TB_producto
    WHERE id_producto = @IdProducto;

    IF @IdEstadoActual IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El producto no existe.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    SELECT @IdEstadoInactivo = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Inactivo';

    IF @IdEstadoActual = @IdEstadoInactivo
        /* Reactivar: Disponible o Agotado según stock */
        SELECT @IdEstadoNuevo = id_estado
        FROM dbo.TB_estado
        WHERE nombre_estado = CASE WHEN @Stock > 0 THEN N'Disponible' ELSE N'Agotado' END;
    ELSE
        SET @IdEstadoNuevo = @IdEstadoInactivo;

    UPDATE dbo.TB_producto
    SET id_estado = @IdEstadoNuevo
    WHERE id_producto = @IdProducto;

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Estado del producto actualizado. El producto dejará de mostrarse para compra si fue desactivado.' AS Mensaje,
           @IdProducto AS IdGenerado;
END;
GO

/* ============================================================
   RF-12: INVENTARIO
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ActualizarStock
    @IdProducto INT,
    @Stock INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EsPiezaUnica BIT, @IdEstadoActual INT, @IdEstadoInactivo INT;

    SELECT @EsPiezaUnica = es_pieza_unica, @IdEstadoActual = id_estado
    FROM dbo.TB_producto
    WHERE id_producto = @IdProducto;

    IF @EsPiezaUnica IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El producto no existe.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    IF @Stock IS NULL OR @Stock < 0
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El stock debe ser mayor o igual a cero.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    IF @EsPiezaUnica = 1 AND @Stock > 1
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'Una pieza única no puede tener stock mayor a 1.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    SELECT @IdEstadoInactivo = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Inactivo';

    UPDATE dbo.TB_producto
    SET stock = @Stock,
        id_estado = CASE
                        WHEN @IdEstadoActual = @IdEstadoInactivo THEN @IdEstadoInactivo
                        WHEN @Stock > 0 THEN (SELECT id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Disponible')
                        ELSE (SELECT id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Agotado')
                    END
    WHERE id_producto = @IdProducto;

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Inventario actualizado correctamente.' AS Mensaje,
           @IdProducto AS IdGenerado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarBajoStock
    @StockMinimo INT = 3
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.id_producto      AS IdProducto,
        P.nombre_producto  AS NombreProducto,
        P.stock            AS Stock,
        C.nombre_categoria AS NombreCategoria,
        E.nombre_estado    AS NombreEstado
    FROM dbo.TB_producto AS P
    INNER JOIN dbo.TB_categoria AS C ON C.id_categoria = P.id_categoria
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = P.id_estado
    WHERE P.stock <= @StockMinimo
      AND E.nombre_estado IN (N'Disponible', N'Agotado')
    ORDER BY P.stock, P.nombre_producto;
END;
GO

/* ============================================================
   RF-11: IMAGENES DE PRODUCTO
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarImagenesProducto
    @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        I.id_imagen    AS IdImagen,
        I.id_producto  AS IdProducto,
        I.ruta_imagen  AS RutaImagen,
        I.es_principal AS EsPrincipal
    FROM dbo.TB_imagen_producto AS I
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = I.id_estado
    WHERE I.id_producto = @IdProducto
      AND E.nombre_estado = N'Activo'
    ORDER BY I.es_principal DESC, I.id_imagen;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_InsertarImagenProducto
    @IdProducto INT,
    @RutaImagen NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.TB_producto WHERE id_producto = @IdProducto)
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El producto no existe.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    DECLARE @IdEstadoActivo INT, @EsPrincipal BIT;

    SELECT @IdEstadoActivo = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Activo';

    /* La primera imagen activa del producto queda como principal */
    IF EXISTS (
        SELECT 1
        FROM dbo.TB_imagen_producto
        WHERE id_producto = @IdProducto
          AND es_principal = 1
          AND id_estado = @IdEstadoActivo
    )
        SET @EsPrincipal = 0;
    ELSE
        SET @EsPrincipal = 1;

    INSERT INTO dbo.TB_imagen_producto (id_producto, ruta_imagen, es_principal, id_estado)
    VALUES (@IdProducto, @RutaImagen, @EsPrincipal, @IdEstadoActivo);

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Imagen agregada correctamente.' AS Mensaje,
           CAST(SCOPE_IDENTITY() AS INT) AS IdGenerado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_MarcarImagenPrincipal
    @IdImagen INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdProducto INT;

    SELECT @IdProducto = id_producto
    FROM dbo.TB_imagen_producto
    WHERE id_imagen = @IdImagen;

    IF @IdProducto IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'La imagen no existe.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    UPDATE dbo.TB_imagen_producto
    SET es_principal = 0
    WHERE id_producto = @IdProducto;

    UPDATE dbo.TB_imagen_producto
    SET es_principal = 1
    WHERE id_imagen = @IdImagen;

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Imagen principal actualizada.' AS Mensaje,
           @IdImagen AS IdGenerado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_EliminarImagenProducto
    @IdImagen INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdProducto INT, @EraPrincipal BIT, @IdEstadoActivo INT, @IdEstadoInactivo INT;

    SELECT @IdProducto = id_producto, @EraPrincipal = es_principal
    FROM dbo.TB_imagen_producto
    WHERE id_imagen = @IdImagen;

    IF @IdProducto IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'La imagen no existe.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    SELECT @IdEstadoActivo = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Activo';
    SELECT @IdEstadoInactivo = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Inactivo';

    UPDATE dbo.TB_imagen_producto
    SET id_estado = @IdEstadoInactivo,
        es_principal = 0
    WHERE id_imagen = @IdImagen;

    /* Si la imagen eliminada era la principal, se promueve otra activa */
    IF @EraPrincipal = 1
    BEGIN
        UPDATE dbo.TB_imagen_producto
        SET es_principal = 1
        WHERE id_imagen = (
            SELECT TOP 1 id_imagen
            FROM dbo.TB_imagen_producto
            WHERE id_producto = @IdProducto
              AND id_estado = @IdEstadoActivo
            ORDER BY id_imagen
        );
    END;

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Imagen eliminada correctamente.' AS Mensaje,
           @IdImagen AS IdGenerado;
END;
GO

/* ============================================================
   RF-13: PEDIDOS ADMINISTRATIVOS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarEstadosPedido
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_estado     AS IdEstado,
        nombre_estado AS NombreEstado
    FROM dbo.TB_estado
    WHERE nombre_estado IN (N'Pagado', N'En preparación', N'Entregado', N'Cancelado')
    ORDER BY id_estado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarPedidos
    @Busqueda NVARCHAR(150) = NULL,
    @IdEstado INT = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL,
    @Pagina INT = 1,
    @TamanoPagina INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @Pagina IS NULL OR @Pagina < 1 SET @Pagina = 1;
    IF @TamanoPagina IS NULL OR @TamanoPagina < 1 SET @TamanoPagina = 10;

    SELECT
        PE.id_pedido       AS IdPedido,
        F.numero_factura   AS NumeroFactura,
        PE.fecha_pedido    AS FechaPedido,
        PE.total           AS Total,
        PE.id_estado       AS IdEstado,
        E.nombre_estado    AS NombreEstado,
        U.nombre + N' ' + U.apellido AS NombreCliente,
        U.email            AS EmailCliente,
        (
            SELECT ISNULL(SUM(DP.cantidad), 0)
            FROM dbo.TB_detalle_pedido AS DP
            WHERE DP.id_pedido = PE.id_pedido
        ) AS CantidadProductos,
        COUNT(*) OVER () AS TotalFilas
    FROM dbo.TB_pedido AS PE
    INNER JOIN dbo.TB_usuario AS U ON U.id_usuario = PE.id_usuario
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = PE.id_estado
    LEFT JOIN dbo.TB_factura AS F ON F.id_pedido = PE.id_pedido
    WHERE (@Busqueda IS NULL OR @Busqueda = N''
           OR U.nombre + N' ' + U.apellido LIKE N'%' + @Busqueda + N'%'
           OR U.email LIKE N'%' + @Busqueda + N'%'
           OR F.numero_factura LIKE N'%' + @Busqueda + N'%')
      AND (@IdEstado IS NULL OR PE.id_estado = @IdEstado)
      AND (@FechaInicio IS NULL OR PE.fecha_pedido >= @FechaInicio)
      AND (@FechaFin IS NULL OR PE.fecha_pedido < DATEADD(DAY, 1, @FechaFin))
    ORDER BY PE.fecha_pedido DESC, PE.id_pedido DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarDetallePedido
    @IdPedido INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PE.id_pedido        AS IdPedido,
        F.numero_factura    AS NumeroFactura,
        PE.fecha_pedido     AS FechaPedido,
        PE.subtotal         AS Subtotal,
        PE.costo_envio      AS CostoEnvio,
        PE.total            AS Total,
        PE.id_estado        AS IdEstado,
        E.nombre_estado     AS NombreEstado,
        PE.motivo_cancelacion AS MotivoCancelacion,
        U.nombre + N' ' + U.apellido AS NombreCliente,
        U.email             AS EmailCliente,
        D.nombre_destinatario AS NombreDestinatario,
        D.telefono_contacto AS TelefonoContacto,
        D.direccion_exacta  AS DireccionExacta,
        DI.nombre_distrito  AS NombreDistrito,
        CA.nombre_canton    AS NombreCanton,
        PR.nombre_provincia AS NombreProvincia,
        MP.nombre_metodo    AS NombreMetodoPago,
        DP.id_producto      AS IdProducto,
        P.nombre_producto   AS NombreProducto,
        DP.cantidad         AS Cantidad,
        DP.precio_unitario  AS PrecioUnitario,
        DP.subtotal_linea   AS SubtotalLinea
    FROM dbo.TB_pedido AS PE
    INNER JOIN dbo.TB_usuario AS U ON U.id_usuario = PE.id_usuario
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = PE.id_estado
    INNER JOIN dbo.TB_direccion_envio AS D ON D.id_direccion = PE.id_direccion
    INNER JOIN dbo.TB_distrito AS DI ON DI.id_distrito = D.id_distrito
    INNER JOIN dbo.TB_canton AS CA ON CA.id_canton = DI.id_canton
    INNER JOIN dbo.TB_provincia AS PR ON PR.id_provincia = CA.id_provincia
    INNER JOIN dbo.TB_detalle_pedido AS DP ON DP.id_pedido = PE.id_pedido
    INNER JOIN dbo.TB_producto AS P ON P.id_producto = DP.id_producto
    LEFT JOIN dbo.TB_factura AS F ON F.id_pedido = PE.id_pedido
    LEFT JOIN dbo.TB_pago AS PA ON PA.id_pedido = PE.id_pedido
    LEFT JOIN dbo.TB_metodo_pago AS MP ON MP.id_metodo_pago = PA.id_metodo_pago
    WHERE PE.id_pedido = @IdPedido
    ORDER BY DP.id_detalle_pedido;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ActualizarEstadoPedido
    @IdPedido INT,
    @IdEstadoNuevo INT,
    @MotivoCancelacion NVARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdEstadoActual INT;
    DECLARE @NombreEstadoActual NVARCHAR(50);
    DECLARE @NombreEstadoNuevo NVARCHAR(50);

    SELECT @IdEstadoActual = id_estado
    FROM dbo.TB_pedido
    WHERE id_pedido = @IdPedido;

    IF @IdEstadoActual IS NULL
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El pedido no existe.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    SELECT @NombreEstadoActual = nombre_estado FROM dbo.TB_estado WHERE id_estado = @IdEstadoActual;
    SELECT @NombreEstadoNuevo = nombre_estado FROM dbo.TB_estado WHERE id_estado = @IdEstadoNuevo;

    IF @NombreEstadoNuevo IS NULL
       OR @NombreEstadoNuevo NOT IN (N'Pagado', N'En preparación', N'Entregado', N'Cancelado')
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El estado seleccionado no es válido para un pedido.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    IF @NombreEstadoActual IN (N'Entregado', N'Cancelado')
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El pedido ya está ' + LOWER(@NombreEstadoActual) + N' y no admite más cambios de estado.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    /* Transiciones válidas:
       Pagado -> En preparación | Cancelado
       En preparación -> Entregado | Cancelado */
    IF NOT (
        (@NombreEstadoActual = N'Pagado' AND @NombreEstadoNuevo IN (N'En preparación', N'Cancelado'))
        OR
        (@NombreEstadoActual = N'En preparación' AND @NombreEstadoNuevo IN (N'Entregado', N'Cancelado'))
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'No es posible pasar de "' + @NombreEstadoActual + N'" a "' + @NombreEstadoNuevo + N'".' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    BEGIN TRY
        BEGIN TRANSACTION;

        /* Al cancelar se devuelve el stock de los productos del pedido */
        IF @NombreEstadoNuevo = N'Cancelado'
        BEGIN
            DECLARE @IdEstadoInactivoProducto INT;

            SELECT @IdEstadoInactivoProducto = id_estado
            FROM dbo.TB_estado
            WHERE nombre_estado = N'Inactivo';

            UPDATE P
            SET P.stock = P.stock + DP.cantidad,
                P.id_estado = CASE
                                  WHEN P.id_estado = @IdEstadoInactivoProducto
                                      THEN P.id_estado
                                  ELSE (SELECT id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Disponible')
                              END
            FROM dbo.TB_producto AS P
            INNER JOIN dbo.TB_detalle_pedido AS DP
                ON DP.id_producto = P.id_producto
            WHERE DP.id_pedido = @IdPedido;
        END;

        UPDATE dbo.TB_pedido
        SET id_estado = @IdEstadoNuevo,
            motivo_cancelacion = CASE
                                     WHEN @NombreEstadoNuevo = N'Cancelado' THEN @MotivoCancelacion
                                     ELSE motivo_cancelacion
                                 END
        WHERE id_pedido = @IdPedido;

        COMMIT TRANSACTION;

        SELECT CAST(1 AS BIT) AS Exitoso,
               N'El pedido cambió al estado "' + @NombreEstadoNuevo + N'".' AS Mensaje,
               @IdPedido AS IdGenerado;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT CAST(0 AS BIT) AS Exitoso,
               N'Ocurrió un error al actualizar el estado del pedido.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
    END CATCH;
END;
GO

/* ============================================================
   RF-14: REPORTES DE VENTAS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ReporteResumenVentas
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ISNULL(SUM(PE.total), 0)  AS TotalVentas,
        COUNT(DISTINCT PE.id_pedido) AS CantidadPedidos,
        ISNULL(SUM(DP.cantidad), 0) AS ProductosVendidos
    FROM dbo.TB_pedido AS PE
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = PE.id_estado
    LEFT JOIN dbo.TB_detalle_pedido AS DP ON DP.id_pedido = PE.id_pedido
    WHERE E.nombre_estado IN (N'Pagado', N'En preparación', N'Entregado')
      AND PE.fecha_pedido >= @FechaInicio
      AND PE.fecha_pedido < DATEADD(DAY, 1, @FechaFin);
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ReporteVentasPorDia
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CAST(PE.fecha_pedido AS DATE) AS Fecha,
        COUNT(DISTINCT PE.id_pedido)  AS CantidadPedidos,
        ISNULL(SUM(PE.total), 0)      AS TotalVentas
    FROM dbo.TB_pedido AS PE
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = PE.id_estado
    WHERE E.nombre_estado IN (N'Pagado', N'En preparación', N'Entregado')
      AND PE.fecha_pedido >= @FechaInicio
      AND PE.fecha_pedido < DATEADD(DAY, 1, @FechaFin)
    GROUP BY CAST(PE.fecha_pedido AS DATE)
    ORDER BY Fecha;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ReporteProductosMasVendidos
    @FechaInicio DATE,
    @FechaFin DATE,
    @Top INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    IF @Top IS NULL OR @Top < 1 SET @Top = 10;

    SELECT TOP (@Top)
        P.id_producto      AS IdProducto,
        P.nombre_producto  AS NombreProducto,
        C.nombre_categoria AS NombreCategoria,
        SUM(DP.cantidad)   AS UnidadesVendidas,
        SUM(DP.subtotal_linea) AS TotalVendido
    FROM dbo.TB_detalle_pedido AS DP
    INNER JOIN dbo.TB_pedido AS PE ON PE.id_pedido = DP.id_pedido
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = PE.id_estado
    INNER JOIN dbo.TB_producto AS P ON P.id_producto = DP.id_producto
    INNER JOIN dbo.TB_categoria AS C ON C.id_categoria = P.id_categoria
    WHERE E.nombre_estado IN (N'Pagado', N'En preparación', N'Entregado')
      AND PE.fecha_pedido >= @FechaInicio
      AND PE.fecha_pedido < DATEADD(DAY, 1, @FechaFin)
    GROUP BY P.id_producto, P.nombre_producto, C.nombre_categoria
    ORDER BY UnidadesVendidas DESC, TotalVendido DESC;
END;
GO
