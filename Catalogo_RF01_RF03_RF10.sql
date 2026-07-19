/* ============================================================
   MODULO DE CATALOGO PUBLICO
   RF-01 Visualizacion del catalogo
   RF-02 Busqueda y filtrado
   RF-03 Detalle de producto (incluye variantes)
   RF-10 Favoritos
   Ejecutar sobre BD_LEN despues de BD_LN.sql y de
   Administracion_RF11_RF14.sql
   ============================================================ */

USE BD_LEN;
GO

/* ============================================================
   TABLAS NUEVAS
   ============================================================ */

IF OBJECT_ID('dbo.TB_variante_producto', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TB_variante_producto
    (
        id_variante INT IDENTITY(1,1) NOT NULL,
        id_producto INT NOT NULL,
        color NVARCHAR(50) NULL,
        talla NVARCHAR(50) NULL,
        modelo NVARCHAR(50) NULL,
        stock INT NOT NULL DEFAULT 0,
        id_estado INT NOT NULL,

        CONSTRAINT PK_TB_variante_producto PRIMARY KEY (id_variante),

        CONSTRAINT FK_TB_variante_producto_TB_producto
            FOREIGN KEY (id_producto) REFERENCES dbo.TB_producto(id_producto),

        CONSTRAINT FK_TB_variante_producto_TB_estado
            FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado)
    );
END;
GO

IF OBJECT_ID('dbo.TB_favorito', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.TB_favorito
    (
        id_favorito INT IDENTITY(1,1) NOT NULL,
        id_usuario INT NOT NULL,
        id_producto INT NOT NULL,
        fecha_agregado DATETIME NOT NULL DEFAULT GETDATE(),

        CONSTRAINT PK_TB_favorito PRIMARY KEY (id_favorito),

        CONSTRAINT FK_TB_favorito_TB_usuario
            FOREIGN KEY (id_usuario) REFERENCES dbo.TB_usuario(id_usuario),

        CONSTRAINT FK_TB_favorito_TB_producto
            FOREIGN KEY (id_producto) REFERENCES dbo.TB_producto(id_producto),

        CONSTRAINT UQ_TB_favorito_usuario_producto UNIQUE (id_usuario, id_producto)
    );
END;
GO

/* ============================================================
   RF-01 / RF-02: CATEGORIAS Y CATALOGO
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarCategoriasCatalogo
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        C.id_categoria     AS IdCategoria,
        C.nombre_categoria AS NombreCategoria
    FROM dbo.TB_categoria AS C
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = C.id_estado
    WHERE E.nombre_estado = N'Activo'
    ORDER BY C.nombre_categoria;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarCatalogo
    @Busqueda NVARCHAR(150) = NULL,
    @IdCategoria INT = NULL,
    @Color NVARCHAR(50) = NULL,
    @IdUsuarioActual INT = NULL,
    @Pagina INT = 1,
    @TamanoPagina INT = 12
AS
BEGIN
    SET NOCOUNT ON;

    IF @Pagina IS NULL OR @Pagina < 1 SET @Pagina = 1;
    IF @TamanoPagina IS NULL OR @TamanoPagina < 1 SET @TamanoPagina = 12;

    /* Solo se muestran productos Disponibles o Agotados;
       un producto Inactivo (desactivado por el administrador)
       no debe aparecer en el catalogo. */
    SELECT
        P.id_producto      AS IdProducto,
        P.nombre_producto  AS NombreProducto,
        P.precio           AS Precio,
        P.id_categoria     AS IdCategoria,
        C.nombre_categoria AS NombreCategoria,
        E.nombre_estado    AS NombreEstado,
        (
            SELECT TOP 1 I.ruta_imagen
            FROM dbo.TB_imagen_producto AS I
            INNER JOIN dbo.TB_estado AS EI ON EI.id_estado = I.id_estado
            WHERE I.id_producto = P.id_producto
              AND EI.nombre_estado = N'Activo'
            ORDER BY I.es_principal DESC, I.id_imagen
        ) AS RutaImagen,
        CASE WHEN @IdUsuarioActual IS NULL THEN CAST(0 AS BIT)
             ELSE CAST((
                 SELECT COUNT(*)
                 FROM dbo.TB_favorito AS F
                 WHERE F.id_usuario = @IdUsuarioActual
                   AND F.id_producto = P.id_producto
             ) AS BIT)
        END AS EsFavorito,
        COUNT(*) OVER () AS TotalFilas
    FROM dbo.TB_producto AS P
    INNER JOIN dbo.TB_categoria AS C ON C.id_categoria = P.id_categoria
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = P.id_estado
    WHERE E.nombre_estado IN (N'Disponible', N'Agotado')
      AND (@Busqueda IS NULL OR @Busqueda = N''
           OR P.nombre_producto LIKE N'%' + @Busqueda + N'%')
      AND (@IdCategoria IS NULL OR P.id_categoria = @IdCategoria)
      AND (@Color IS NULL OR @Color = N'' OR EXISTS (
            SELECT 1
            FROM dbo.TB_variante_producto AS V
            INNER JOIN dbo.TB_estado AS EV ON EV.id_estado = V.id_estado
            WHERE V.id_producto = P.id_producto
              AND EV.nombre_estado = N'Activo'
              AND V.color = @Color
      ))
    ORDER BY P.destacado DESC, P.fecha_creacion DESC, P.id_producto DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

/* ============================================================
   RF-03: DETALLE DE PRODUCTO
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarProductoDetalle
    @IdProducto INT,
    @IdUsuarioActual INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    /* Si el producto esta Inactivo no se retorna nada:
       para el cliente es como si no existiera. */
    SELECT
        P.id_producto      AS IdProducto,
        P.nombre_producto  AS NombreProducto,
        P.descripcion      AS Descripcion,
        P.precio           AS Precio,
        P.stock            AS Stock,
        P.es_pieza_unica   AS EsPiezaUnica,
        P.id_categoria     AS IdCategoria,
        C.nombre_categoria AS NombreCategoria,
        E.nombre_estado    AS NombreEstado,
        CASE WHEN @IdUsuarioActual IS NULL THEN CAST(0 AS BIT)
             ELSE CAST((
                 SELECT COUNT(*)
                 FROM dbo.TB_favorito AS F
                 WHERE F.id_usuario = @IdUsuarioActual
                   AND F.id_producto = P.id_producto
             ) AS BIT)
        END AS EsFavorito
    FROM dbo.TB_producto AS P
    INNER JOIN dbo.TB_categoria AS C ON C.id_categoria = P.id_categoria
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = P.id_estado
    WHERE P.id_producto = @IdProducto
      AND E.nombre_estado IN (N'Disponible', N'Agotado');
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarImagenesCatalogo
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

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarVariantesProducto
    @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        V.id_variante AS IdVariante,
        V.color       AS Color,
        V.talla       AS Talla,
        V.modelo      AS Modelo,
        V.stock       AS Stock
    FROM dbo.TB_variante_producto AS V
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = V.id_estado
    WHERE V.id_producto = @IdProducto
      AND E.nombre_estado = N'Activo'
    ORDER BY V.id_variante;
END;
GO

/* ============================================================
   RF-10: FAVORITOS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_AgregarFavorito
    @IdUsuario INT,
    @IdProducto INT
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

    IF EXISTS (
        SELECT 1 FROM dbo.TB_favorito
        WHERE id_usuario = @IdUsuario AND id_producto = @IdProducto
    )
    BEGIN
        SELECT CAST(1 AS BIT) AS Exitoso,
               N'El producto ya estaba en sus favoritos.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    INSERT INTO dbo.TB_favorito (id_usuario, id_producto)
    VALUES (@IdUsuario, @IdProducto);

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Producto agregado a favoritos.' AS Mensaje,
           CAST(SCOPE_IDENTITY() AS INT) AS IdGenerado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_EliminarFavorito
    @IdUsuario INT,
    @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.TB_favorito
        WHERE id_usuario = @IdUsuario AND id_producto = @IdProducto
    )
    BEGIN
        SELECT CAST(0 AS BIT) AS Exitoso,
               N'El producto no estaba en sus favoritos.' AS Mensaje,
               CAST(NULL AS INT) AS IdGenerado;
        RETURN;
    END;

    DELETE FROM dbo.TB_favorito
    WHERE id_usuario = @IdUsuario AND id_producto = @IdProducto;

    SELECT CAST(1 AS BIT) AS Exitoso,
           N'Producto retirado de favoritos.' AS Mensaje,
           @IdProducto AS IdGenerado;
END;
GO

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarFavoritos
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        P.id_producto      AS IdProducto,
        P.nombre_producto  AS NombreProducto,
        P.precio           AS Precio,
        C.nombre_categoria AS NombreCategoria,
        E.nombre_estado    AS NombreEstado,
        (
            SELECT TOP 1 I.ruta_imagen
            FROM dbo.TB_imagen_producto AS I
            INNER JOIN dbo.TB_estado AS EI ON EI.id_estado = I.id_estado
            WHERE I.id_producto = P.id_producto
              AND EI.nombre_estado = N'Activo'
            ORDER BY I.es_principal DESC, I.id_imagen
        ) AS RutaImagen
    FROM dbo.TB_favorito AS F
    INNER JOIN dbo.TB_producto AS P ON P.id_producto = F.id_producto
    INNER JOIN dbo.TB_categoria AS C ON C.id_categoria = P.id_categoria
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = P.id_estado
    WHERE F.id_usuario = @IdUsuario
    ORDER BY F.fecha_agregado DESC;
END;
GO
