/* ============================================================
   BASE DE DATOS: BD_LEN
   Proyecto: LEN - Tienda de accesorios
   ============================================================ */

IF DB_ID(N'BD_LEN') IS NULL
BEGIN
    CREATE DATABASE BD_LEN;
END
GO

USE BD_LEN;
GO

/* ============================================================
   TABLAS CATÁLOGO
   ============================================================ */

CREATE TABLE dbo.TB_rol
(
    id_rol INT IDENTITY(1,1) NOT NULL,
    nombre_rol NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_TB_rol PRIMARY KEY (id_rol),
    CONSTRAINT UQ_TB_rol_nombre UNIQUE (nombre_rol)
);
GO

CREATE TABLE dbo.TB_estado
(
    id_estado INT IDENTITY(1,1) NOT NULL,
    nombre_estado NVARCHAR(50) NOT NULL,

    CONSTRAINT PK_TB_estado PRIMARY KEY (id_estado),
    CONSTRAINT UQ_TB_estado_nombre UNIQUE (nombre_estado)
);
GO

/* ============================================================
   USUARIOS
   ============================================================ */

CREATE TABLE dbo.TB_usuario
(
    id_usuario INT IDENTITY(1,1) NOT NULL,
    nombre NVARCHAR(100) NOT NULL,
    apellido NVARCHAR(100) NOT NULL,
    cedula NVARCHAR(20) NULL,
    telefono NVARCHAR(20) NULL,
    email NVARCHAR(150) NOT NULL,
    contrasena NVARCHAR(255) NOT NULL,
    id_rol INT NOT NULL,
    id_estado INT NOT NULL,
    fecha_registro DATETIME2(0) NOT NULL CONSTRAINT DF_TB_usuario_fecha_registro DEFAULT SYSDATETIME(),

    CONSTRAINT PK_TB_usuario PRIMARY KEY (id_usuario),

    CONSTRAINT UQ_TB_usuario_email UNIQUE (email),

    CONSTRAINT FK_TB_usuario_TB_rol
        FOREIGN KEY (id_rol) REFERENCES dbo.TB_rol(id_rol),

    CONSTRAINT FK_TB_usuario_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado)
);
GO

CREATE UNIQUE INDEX UX_TB_usuario_cedula
ON dbo.TB_usuario(cedula)
WHERE cedula IS NOT NULL;
GO

/* ============================================================
   UBICACIÓN COSTA RICA
   ============================================================ */

CREATE TABLE dbo.TB_provincia
(
    id_provincia INT IDENTITY(1,1) NOT NULL,
    nombre_provincia NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_TB_provincia PRIMARY KEY (id_provincia),
    CONSTRAINT UQ_TB_provincia_nombre UNIQUE (nombre_provincia)
);
GO

CREATE TABLE dbo.TB_canton
(
    id_canton INT IDENTITY(1,1) NOT NULL,
    id_provincia INT NOT NULL,
    nombre_canton NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_TB_canton PRIMARY KEY (id_canton),

    CONSTRAINT FK_TB_canton_TB_provincia
        FOREIGN KEY (id_provincia) REFERENCES dbo.TB_provincia(id_provincia),

    CONSTRAINT UQ_TB_canton_provincia_nombre UNIQUE (id_provincia, nombre_canton)
);
GO

CREATE TABLE dbo.TB_distrito
(
    id_distrito INT IDENTITY(1,1) NOT NULL,
    id_canton INT NOT NULL,
    nombre_distrito NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_TB_distrito PRIMARY KEY (id_distrito),

    CONSTRAINT FK_TB_distrito_TB_canton
        FOREIGN KEY (id_canton) REFERENCES dbo.TB_canton(id_canton),

    CONSTRAINT UQ_TB_distrito_canton_nombre UNIQUE (id_canton, nombre_distrito)
);
GO

CREATE TABLE dbo.TB_direccion_envio
(
    id_direccion INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    id_distrito INT NOT NULL,
    direccion_exacta NVARCHAR(300) NOT NULL,
    referencia NVARCHAR(300) NULL,
    telefono_contacto NVARCHAR(20) NOT NULL,
    nombre_destinatario NVARCHAR(150) NOT NULL,
    es_principal BIT NOT NULL CONSTRAINT DF_TB_direccion_envio_es_principal DEFAULT 0,
    id_estado INT NOT NULL,

    CONSTRAINT PK_TB_direccion_envio PRIMARY KEY (id_direccion),

    CONSTRAINT FK_TB_direccion_envio_TB_usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.TB_usuario(id_usuario),

    CONSTRAINT FK_TB_direccion_envio_TB_distrito
        FOREIGN KEY (id_distrito) REFERENCES dbo.TB_distrito(id_distrito),

    CONSTRAINT FK_TB_direccion_envio_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado)
);
GO

CREATE UNIQUE INDEX UX_TB_direccion_envio_principal_usuario
ON dbo.TB_direccion_envio(id_usuario)
WHERE es_principal = 1;
GO

/* ============================================================
   PRODUCTOS
   ============================================================ */

CREATE TABLE dbo.TB_categoria
(
    id_categoria INT IDENTITY(1,1) NOT NULL,
    nombre_categoria NVARCHAR(100) NOT NULL,
    descripcion NVARCHAR(255) NULL,
    id_estado INT NOT NULL,

    CONSTRAINT PK_TB_categoria PRIMARY KEY (id_categoria),

    CONSTRAINT UQ_TB_categoria_nombre UNIQUE (nombre_categoria),

    CONSTRAINT FK_TB_categoria_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado)
);
GO

CREATE TABLE dbo.TB_producto
(
    id_producto INT IDENTITY(1,1) NOT NULL,
    nombre_producto NVARCHAR(150) NOT NULL,
    descripcion NVARCHAR(MAX) NULL,
    precio DECIMAL(10,2) NOT NULL,
    stock INT NOT NULL,
    es_pieza_unica BIT NOT NULL CONSTRAINT DF_TB_producto_es_pieza_unica DEFAULT 0,
    destacado BIT NOT NULL CONSTRAINT DF_TB_producto_destacado DEFAULT 0,
    id_categoria INT NOT NULL,
    id_estado INT NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL CONSTRAINT DF_TB_producto_fecha_creacion DEFAULT SYSDATETIME(),

    CONSTRAINT PK_TB_producto PRIMARY KEY (id_producto),

    CONSTRAINT FK_TB_producto_TB_categoria
        FOREIGN KEY (id_categoria) REFERENCES dbo.TB_categoria(id_categoria),

    CONSTRAINT FK_TB_producto_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado),

    CONSTRAINT CK_TB_producto_precio CHECK (precio >= 0),
    CONSTRAINT CK_TB_producto_stock CHECK (stock >= 0),
    CONSTRAINT CK_TB_producto_pieza_unica_stock CHECK 
    (
        es_pieza_unica = 0 OR stock <= 1
    )
);
GO

CREATE TABLE dbo.TB_imagen_producto
(
    id_imagen INT IDENTITY(1,1) NOT NULL,
    id_producto INT NOT NULL,
    ruta_imagen NVARCHAR(255) NOT NULL,
    es_principal BIT NOT NULL CONSTRAINT DF_TB_imagen_producto_es_principal DEFAULT 0,
    id_estado INT NOT NULL,

    CONSTRAINT PK_TB_imagen_producto PRIMARY KEY (id_imagen),

    CONSTRAINT FK_TB_imagen_producto_TB_producto
        FOREIGN KEY (id_producto) REFERENCES dbo.TB_producto(id_producto),

    CONSTRAINT FK_TB_imagen_producto_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado)
);
GO

CREATE UNIQUE INDEX UX_TB_imagen_producto_principal_producto
ON dbo.TB_imagen_producto(id_producto)
WHERE es_principal = 1;
GO

/* ============================================================
   PEDIDOS Y DETALLE DE PEDIDO
   ============================================================ */

CREATE TABLE dbo.TB_pedido
(
    id_pedido INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    id_direccion INT NOT NULL,
    fecha_pedido DATETIME2(0) NOT NULL CONSTRAINT DF_TB_pedido_fecha_pedido DEFAULT SYSDATETIME(),
    subtotal DECIMAL(10,2) NOT NULL CONSTRAINT DF_TB_pedido_subtotal DEFAULT 0,
    costo_envio DECIMAL(10,2) NOT NULL CONSTRAINT DF_TB_pedido_costo_envio DEFAULT 0,
    total DECIMAL(10,2) NOT NULL CONSTRAINT DF_TB_pedido_total DEFAULT 0,
    id_estado INT NOT NULL,

    CONSTRAINT PK_TB_pedido PRIMARY KEY (id_pedido),

    CONSTRAINT FK_TB_pedido_TB_usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.TB_usuario(id_usuario),

    CONSTRAINT FK_TB_pedido_TB_direccion_envio
        FOREIGN KEY (id_direccion) REFERENCES dbo.TB_direccion_envio(id_direccion),

    CONSTRAINT FK_TB_pedido_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado),

    CONSTRAINT CK_TB_pedido_subtotal CHECK (subtotal >= 0),
    CONSTRAINT CK_TB_pedido_costo_envio CHECK (costo_envio >= 0),
    CONSTRAINT CK_TB_pedido_total CHECK (total >= 0)
);
GO

CREATE TABLE dbo.TB_detalle_pedido
(
    id_detalle_pedido INT IDENTITY(1,1) NOT NULL,
    id_pedido INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,
    subtotal_linea DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_TB_detalle_pedido PRIMARY KEY (id_detalle_pedido),

    CONSTRAINT FK_TB_detalle_pedido_TB_pedido
        FOREIGN KEY (id_pedido) REFERENCES dbo.TB_pedido(id_pedido),

    CONSTRAINT FK_TB_detalle_pedido_TB_producto
        FOREIGN KEY (id_producto) REFERENCES dbo.TB_producto(id_producto),

    CONSTRAINT CK_TB_detalle_pedido_cantidad CHECK (cantidad > 0),
    CONSTRAINT CK_TB_detalle_pedido_precio_unitario CHECK (precio_unitario >= 0),
    CONSTRAINT CK_TB_detalle_pedido_subtotal_linea CHECK (subtotal_linea >= 0)
);
GO

/* ============================================================
   FACTURA
   ============================================================ */

CREATE TABLE dbo.TB_factura
(
    id_factura INT IDENTITY(1,1) NOT NULL,
    id_pedido INT NOT NULL,
    numero_factura NVARCHAR(50) NOT NULL,
    fecha_factura DATETIME2(0) NOT NULL CONSTRAINT DF_TB_factura_fecha_factura DEFAULT SYSDATETIME(),
    subtotal DECIMAL(10,2) NOT NULL,
    costo_envio DECIMAL(10,2) NOT NULL,
    total DECIMAL(10,2) NOT NULL,
    id_estado INT NOT NULL,

    CONSTRAINT PK_TB_factura PRIMARY KEY (id_factura),

    CONSTRAINT UQ_TB_factura_id_pedido UNIQUE (id_pedido),
    CONSTRAINT UQ_TB_factura_numero_factura UNIQUE (numero_factura),

    CONSTRAINT FK_TB_factura_TB_pedido
        FOREIGN KEY (id_pedido) REFERENCES dbo.TB_pedido(id_pedido),

    CONSTRAINT FK_TB_factura_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado),

    CONSTRAINT CK_TB_factura_subtotal CHECK (subtotal >= 0),
    CONSTRAINT CK_TB_factura_costo_envio CHECK (costo_envio >= 0),
    CONSTRAINT CK_TB_factura_total CHECK (total >= 0)
);
GO

/* ============================================================
   PAGOS
   ============================================================ */

CREATE TABLE dbo.TB_metodo_pago
(
    id_metodo_pago INT IDENTITY(1,1) NOT NULL,
    nombre_metodo NVARCHAR(100) NOT NULL,
    id_estado INT NOT NULL,

    CONSTRAINT PK_TB_metodo_pago PRIMARY KEY (id_metodo_pago),

    CONSTRAINT UQ_TB_metodo_pago_nombre UNIQUE (nombre_metodo),

    CONSTRAINT FK_TB_metodo_pago_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado)
);
GO

CREATE TABLE dbo.TB_pago
(
    id_pago INT IDENTITY(1,1) NOT NULL,
    id_pedido INT NOT NULL,
    id_metodo_pago INT NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    fecha_pago DATETIME2(0) NOT NULL CONSTRAINT DF_TB_pago_fecha_pago DEFAULT SYSDATETIME(),
    comprobante NVARCHAR(255) NULL,
    id_estado INT NOT NULL,

    CONSTRAINT PK_TB_pago PRIMARY KEY (id_pago),

    CONSTRAINT FK_TB_pago_TB_pedido
        FOREIGN KEY (id_pedido) REFERENCES dbo.TB_pedido(id_pedido),

    CONSTRAINT FK_TB_pago_TB_metodo_pago
        FOREIGN KEY (id_metodo_pago) REFERENCES dbo.TB_metodo_pago(id_metodo_pago),

    CONSTRAINT FK_TB_pago_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado),

    CONSTRAINT CK_TB_pago_monto CHECK (monto >= 0)
);
GO

/* ============================================================
   CARRITO
   ============================================================ */

CREATE TABLE dbo.TB_carrito
(
    id_carrito INT IDENTITY(1,1) NOT NULL,
    id_usuario INT NOT NULL,
    fecha_creacion DATETIME2(0) NOT NULL CONSTRAINT DF_TB_carrito_fecha_creacion DEFAULT SYSDATETIME(),
    id_estado INT NOT NULL,

    CONSTRAINT PK_TB_carrito PRIMARY KEY (id_carrito),

    CONSTRAINT FK_TB_carrito_TB_usuario
        FOREIGN KEY (id_usuario) REFERENCES dbo.TB_usuario(id_usuario),

    CONSTRAINT FK_TB_carrito_TB_estado
        FOREIGN KEY (id_estado) REFERENCES dbo.TB_estado(id_estado)
);
GO

CREATE TABLE dbo.TB_detalle_carrito
(
    id_detalle_carrito INT IDENTITY(1,1) NOT NULL,
    id_carrito INT NOT NULL,
    id_producto INT NOT NULL,
    cantidad INT NOT NULL,

    CONSTRAINT PK_TB_detalle_carrito PRIMARY KEY (id_detalle_carrito),

    CONSTRAINT FK_TB_detalle_carrito_TB_carrito
        FOREIGN KEY (id_carrito) REFERENCES dbo.TB_carrito(id_carrito),

    CONSTRAINT FK_TB_detalle_carrito_TB_producto
        FOREIGN KEY (id_producto) REFERENCES dbo.TB_producto(id_producto),

    CONSTRAINT CK_TB_detalle_carrito_cantidad CHECK (cantidad > 0),

    CONSTRAINT UQ_TB_detalle_carrito_producto UNIQUE (id_carrito, id_producto)
);
GO

/* ============================================================
   TABLA DE ERRORES
   Esta tabla no tiene relación con ninguna otra.
   Se puede usar dentro de TRY/CATCH desde la aplicación.
   ============================================================ */

CREATE TABLE dbo.TB_error
(
    id_error INT IDENTITY(1,1) NOT NULL,
    fecha_error DATETIME2(0) NOT NULL CONSTRAINT DF_TB_error_fecha_error DEFAULT SYSDATETIME(),
    origen NVARCHAR(150) NULL,
    metodo NVARCHAR(150) NULL,
    mensaje_error NVARCHAR(MAX) NOT NULL,
    detalle_error NVARCHAR(MAX) NULL,
    linea_error INT NULL,
    usuario_sistema NVARCHAR(150) NULL,
    url NVARCHAR(500) NULL,
    stack_trace NVARCHAR(MAX) NULL,

    CONSTRAINT PK_TB_error PRIMARY KEY (id_error)
);
GO

/* ============================================================
   DATOS BASE RECOMENDADOS
   ============================================================ */

INSERT INTO dbo.TB_rol (nombre_rol)
SELECT N'Administrador'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_rol WHERE nombre_rol = N'Administrador');

INSERT INTO dbo.TB_rol (nombre_rol)
SELECT N'Cliente'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_rol WHERE nombre_rol = N'Cliente');
GO

INSERT INTO dbo.TB_estado (nombre_estado)
SELECT N'Activo'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_estado WHERE nombre_estado = N'Activo');

INSERT INTO dbo.TB_estado (nombre_estado)
SELECT N'Inactivo'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_estado WHERE nombre_estado = N'Inactivo');

INSERT INTO dbo.TB_estado (nombre_estado)
SELECT N'Disponible'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_estado WHERE nombre_estado = N'Disponible');

INSERT INTO dbo.TB_estado (nombre_estado)
SELECT N'Agotado'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_estado WHERE nombre_estado = N'Agotado');

INSERT INTO dbo.TB_estado (nombre_estado)
SELECT N'Pendiente'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_estado WHERE nombre_estado = N'Pendiente');

INSERT INTO dbo.TB_estado (nombre_estado)
SELECT N'Pagado'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_estado WHERE nombre_estado = N'Pagado');

INSERT INTO dbo.TB_estado (nombre_estado)
SELECT N'Cancelado'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_estado WHERE nombre_estado = N'Cancelado');

INSERT INTO dbo.TB_estado (nombre_estado)
SELECT N'Entregado'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_estado WHERE nombre_estado = N'Entregado');

INSERT INTO dbo.TB_estado (nombre_estado)
SELECT N'En preparación'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_estado WHERE nombre_estado = N'En preparación');
GO

INSERT INTO dbo.TB_provincia (nombre_provincia)
SELECT N'San José'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_provincia WHERE nombre_provincia = N'San José');

INSERT INTO dbo.TB_provincia (nombre_provincia)
SELECT N'Alajuela'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_provincia WHERE nombre_provincia = N'Alajuela');

INSERT INTO dbo.TB_provincia (nombre_provincia)
SELECT N'Cartago'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_provincia WHERE nombre_provincia = N'Cartago');

INSERT INTO dbo.TB_provincia (nombre_provincia)
SELECT N'Heredia'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_provincia WHERE nombre_provincia = N'Heredia');

INSERT INTO dbo.TB_provincia (nombre_provincia)
SELECT N'Guanacaste'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_provincia WHERE nombre_provincia = N'Guanacaste');

INSERT INTO dbo.TB_provincia (nombre_provincia)
SELECT N'Puntarenas'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_provincia WHERE nombre_provincia = N'Puntarenas');

INSERT INTO dbo.TB_provincia (nombre_provincia)
SELECT N'Limón'
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_provincia WHERE nombre_provincia = N'Limón');
GO

DECLARE @IdEstadoActivo INT;
SELECT @IdEstadoActivo = id_estado 
FROM dbo.TB_estado 
WHERE nombre_estado = N'Activo';

INSERT INTO dbo.TB_metodo_pago (nombre_metodo, id_estado)
SELECT N'SINPE Móvil', @IdEstadoActivo
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_metodo_pago WHERE nombre_metodo = N'SINPE Móvil');

INSERT INTO dbo.TB_metodo_pago (nombre_metodo, id_estado)
SELECT N'Transferencia bancaria', @IdEstadoActivo
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_metodo_pago WHERE nombre_metodo = N'Transferencia bancaria');

INSERT INTO dbo.TB_metodo_pago (nombre_metodo, id_estado)
SELECT N'Efectivo contra entrega', @IdEstadoActivo
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_metodo_pago WHERE nombre_metodo = N'Efectivo contra entrega');

INSERT INTO dbo.TB_metodo_pago (nombre_metodo, id_estado)
SELECT N'Tarjeta', @IdEstadoActivo
WHERE NOT EXISTS (SELECT 1 FROM dbo.TB_metodo_pago WHERE nombre_metodo = N'Tarjeta');
GO

/* ============================================================
   SELECTS PARA COMPROBAR DATOS INICIALES
   ============================================================ */

   SELECT * FROM  TB_estado;      
   SELECT * FROM  TB_rol;
   SELECT * FROM  TB_provincia;
   SELECT * FROM  TB_metodo_pago;


   SELECT * FROM TB_usuario;


   /* ============================================================
   Carrito
   COLUMNAS DE CONTRASEÑA TEMPORAL (adelantadas)
   ============================================================ */

IF COL_LENGTH('dbo.TB_usuario', 'tiene_contrasenna_temporal') IS NULL
BEGIN
    ALTER TABLE dbo.TB_usuario
    ADD tiene_contrasenna_temporal BIT NOT NULL
        CONSTRAINT DF_TB_usuario_contrasenna_temporal DEFAULT 0;
END;
GO

IF COL_LENGTH('dbo.TB_usuario', 'vigencia_contrasenna_temporal') IS NULL
BEGIN
    ALTER TABLE dbo.TB_usuario
    ADD vigencia_contrasenna_temporal DATETIME2(0) NULL;
END;
GO

   /* ============================================================
   PROCEDIMIENTO ALMACENADO INICIO DE SESION
   ============================================================ */
   GO

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarUsuarioInicioSesion
    @Email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.id_usuario AS IdUsuario,
        U.nombre AS Nombre,
        U.apellido AS Apellido,
        U.email AS Email,
        U.contrasena AS Contrasenna,
        U.id_rol AS IdRol,
        R.nombre_rol AS NombreRol,
        U.id_estado AS IdEstado,
        E.nombre_estado AS NombreEstado,

        U.tiene_contrasenna_temporal
            AS TieneContrasennaTemporal,

        U.vigencia_contrasenna_temporal
            AS VigenciaContrasennaTemporal

    FROM dbo.TB_usuario AS U

    INNER JOIN dbo.TB_rol AS R
        ON R.id_rol = U.id_rol

    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = U.id_estado

    WHERE LOWER(LTRIM(RTRIM(U.email))) =
          LOWER(LTRIM(RTRIM(@Email)));
END;
GO

   /* ============================================================
   PROCEDIMIENTO ALMACENADO REGISTRO DE ERRORES
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_RegistrarError
    @Origen NVARCHAR(150) = NULL,
    @Metodo NVARCHAR(150) = NULL,
    @MensajeError NVARCHAR(MAX),
    @DetalleError NVARCHAR(MAX) = NULL,
    @LineaError INT = NULL,
    @UsuarioSistema NVARCHAR(150) = NULL,
    @Url NVARCHAR(500) = NULL,
    @StackTrace NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.TB_error
    (
        origen,
        metodo,
        mensaje_error,
        detalle_error,
        linea_error,
        usuario_sistema,
        url,
        stack_trace
    )
    VALUES
    (
        @Origen,
        @Metodo,
        @MensajeError,
        @DetalleError,
        @LineaError,
        @UsuarioSistema,
        @Url,
        @StackTrace
    );
END;
GO

  /* ============================================================
  CONSLTAR USUARIO POR IDENTIFICADOR
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarUsuarioPorId
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.id_usuario AS IdUsuario,
        U.nombre AS Nombre,
        U.apellido AS Apellido,
        U.cedula AS Cedula,
        U.telefono AS Telefono,
        U.email AS Email,
        U.id_rol AS IdRol,
        R.nombre_rol AS NombreRol,
        U.id_estado AS IdEstado,
        E.nombre_estado AS NombreEstado,
        U.fecha_registro AS FechaRegistro
    FROM dbo.TB_usuario AS U
    INNER JOIN dbo.TB_rol AS R
        ON R.id_rol = U.id_rol
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = U.id_estado
    WHERE U.id_usuario = @IdUsuario;
END;
GO

  /* ============================================================
  ACTUALIZAR DATOS USUARIO
   ============================================================ */

   CREATE OR ALTER PROCEDURE dbo.SP_ActualizarUsuario
    @IdUsuario INT,
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Cedula NVARCHAR(20) = NULL,
    @Telefono NVARCHAR(20) = NULL,
    @Email NVARCHAR(150),
    @IdRol INT,
    @IdEstado INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.TB_usuario
        WHERE LOWER(LTRIM(RTRIM(email))) =
              LOWER(LTRIM(RTRIM(@Email)))
          AND id_usuario <> @IdUsuario
    )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El correo electrónico ya está registrado.' AS Mensaje;

        RETURN;
    END;

    IF @Cedula IS NOT NULL
       AND LTRIM(RTRIM(@Cedula)) <> ''
       AND EXISTS
       (
           SELECT 1
           FROM dbo.TB_usuario
           WHERE cedula = LTRIM(RTRIM(@Cedula))
             AND id_usuario <> @IdUsuario
       )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'La cédula ya está registrada.' AS Mensaje;

        RETURN;
    END;

    UPDATE dbo.TB_usuario
    SET
        nombre = LTRIM(RTRIM(@Nombre)),
        apellido = LTRIM(RTRIM(@Apellido)),
        cedula = NULLIF(LTRIM(RTRIM(@Cedula)), ''),
        telefono = NULLIF(LTRIM(RTRIM(@Telefono)), ''),
        email = LOWER(LTRIM(RTRIM(@Email))),
        id_rol = @IdRol,
        id_estado = @IdEstado
    WHERE id_usuario = @IdUsuario;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No se encontró el usuario.' AS Mensaje;

        RETURN;
    END;

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'El usuario fue actualizado correctamente.' AS Mensaje;
END;
GO

  /* ============================================================
  RESTABLECER CONTRASEÑA
   ============================================================ */
   CREATE OR ALTER PROCEDURE dbo.SP_RestablecerContrasennaUsuario
    @IdUsuario INT,
    @Contrasenna NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.TB_usuario
    SET contrasena = @Contrasenna
    WHERE id_usuario = @IdUsuario;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No se encontró el usuario.' AS Mensaje;

        RETURN;
    END;

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'La contraseña fue restablecida correctamente.' AS Mensaje;
END;
GO

   /* ============================================================
   CONSULTAR DIRECCIONES
   ============================================================ */
   CREATE OR ALTER PROCEDURE dbo.SP_ConsultarDireccionesUsuario
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DE.id_direccion AS IdDireccion,
        DE.id_usuario AS IdUsuario,
        P.id_provincia AS IdProvincia,
        P.nombre_provincia AS NombreProvincia,
        C.id_canton AS IdCanton,
        C.nombre_canton AS NombreCanton,
        D.id_distrito AS IdDistrito,
        D.nombre_distrito AS NombreDistrito,
        DE.direccion_exacta AS DireccionExacta,
        DE.referencia AS Referencia,
        DE.telefono_contacto AS TelefonoContacto,
        DE.nombre_destinatario AS NombreDestinatario,
        DE.es_principal AS EsPrincipal,
        DE.id_estado AS IdEstado,
        E.nombre_estado AS NombreEstado
    FROM dbo.TB_direccion_envio AS DE
    INNER JOIN dbo.TB_distrito AS D
        ON D.id_distrito = DE.id_distrito
    INNER JOIN dbo.TB_canton AS C
        ON C.id_canton = D.id_canton
    INNER JOIN dbo.TB_provincia AS P
        ON P.id_provincia = C.id_provincia
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = DE.id_estado
    WHERE DE.id_usuario = @IdUsuario
    ORDER BY
        DE.es_principal DESC,
        DE.id_direccion DESC;
END;
GO

   /* ============================================================
   INSERTAR DIRECCIONES
   ============================================================ */

   CREATE OR ALTER PROCEDURE dbo.SP_InsertarDireccionUsuario
    @IdUsuario INT,
    @IdDistrito INT,
    @DireccionExacta NVARCHAR(300),
    @Referencia NVARCHAR(300) = NULL,
    @TelefonoContacto NVARCHAR(20),
    @NombreDestinatario NVARCHAR(150),
    @EsPrincipal BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdEstadoActivo INT;

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    BEGIN TRANSACTION;

    IF @EsPrincipal = 1
    BEGIN
        UPDATE dbo.TB_direccion_envio
        SET es_principal = 0
        WHERE id_usuario = @IdUsuario;
    END;

    INSERT INTO dbo.TB_direccion_envio
    (
        id_usuario,
        id_distrito,
        direccion_exacta,
        referencia,
        telefono_contacto,
        nombre_destinatario,
        es_principal,
        id_estado
    )
    VALUES
    (
        @IdUsuario,
        @IdDistrito,
        LTRIM(RTRIM(@DireccionExacta)),
        NULLIF(LTRIM(RTRIM(@Referencia)), ''),
        LTRIM(RTRIM(@TelefonoContacto)),
        LTRIM(RTRIM(@NombreDestinatario)),
        @EsPrincipal,
        @IdEstadoActivo
    );

    DECLARE @IdDireccion INT = SCOPE_IDENTITY();

    COMMIT TRANSACTION;

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'La dirección fue agregada correctamente.' AS Mensaje,
        @IdDireccion AS IdDireccion;
END;
GO

   /* ============================================================
   CONSULTAR DIRECCION POR ID
   ============================================================ */
   CREATE OR ALTER PROCEDURE dbo.SP_ConsultarDireccionPorId
    @IdDireccion INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        DE.id_direccion AS IdDireccion,
        DE.id_usuario AS IdUsuario,
        P.id_provincia AS IdProvincia,
        P.nombre_provincia AS NombreProvincia,
        C.id_canton AS IdCanton,
        C.nombre_canton AS NombreCanton,
        D.id_distrito AS IdDistrito,
        D.nombre_distrito AS NombreDistrito,
        DE.direccion_exacta AS DireccionExacta,
        DE.referencia AS Referencia,
        DE.telefono_contacto AS TelefonoContacto,
        DE.nombre_destinatario AS NombreDestinatario,
        DE.es_principal AS EsPrincipal,
        DE.id_estado AS IdEstado,
        E.nombre_estado AS NombreEstado
    FROM dbo.TB_direccion_envio AS DE
    INNER JOIN dbo.TB_distrito AS D
        ON D.id_distrito = DE.id_distrito
    INNER JOIN dbo.TB_canton AS C
        ON C.id_canton = D.id_canton
    INNER JOIN dbo.TB_provincia AS P
        ON P.id_provincia = C.id_provincia
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = DE.id_estado
    WHERE DE.id_direccion = @IdDireccion
      AND DE.id_usuario = @IdUsuario;
END;
GO

   /* ============================================================
   ACTUALIZAR DIRECCION
   ============================================================ */
   CREATE OR ALTER PROCEDURE dbo.SP_ActualizarDireccionUsuario
    @IdDireccion INT,
    @IdUsuario INT,
    @IdDistrito INT,
    @DireccionExacta NVARCHAR(300),
    @Referencia NVARCHAR(300) = NULL,
    @TelefonoContacto NVARCHAR(20),
    @NombreDestinatario NVARCHAR(150),
    @EsPrincipal BIT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    IF @EsPrincipal = 1
    BEGIN
        UPDATE dbo.TB_direccion_envio
        SET es_principal = 0
        WHERE id_usuario = @IdUsuario
          AND id_direccion <> @IdDireccion;
    END;

    UPDATE dbo.TB_direccion_envio
    SET
        id_distrito = @IdDistrito,
        direccion_exacta = LTRIM(RTRIM(@DireccionExacta)),
        referencia = NULLIF(LTRIM(RTRIM(@Referencia)), ''),
        telefono_contacto = LTRIM(RTRIM(@TelefonoContacto)),
        nombre_destinatario = LTRIM(RTRIM(@NombreDestinatario)),
        es_principal = @EsPrincipal
    WHERE id_direccion = @IdDireccion
      AND id_usuario = @IdUsuario;

    DECLARE @FilasAfectadas INT = @@ROWCOUNT;

    COMMIT TRANSACTION;

    IF @FilasAfectadas = 0
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No se encontró la dirección.' AS Mensaje;

        RETURN;
    END;

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'La dirección fue actualizada correctamente.' AS Mensaje;
END;
GO

   /* ============================================================
  DESACTIVAR DIRECCION
   ============================================================ */
   CREATE OR ALTER PROCEDURE dbo.SP_DesactivarDireccionUsuario
    @IdDireccion INT,
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoInactivo INT;

    SELECT @IdEstadoInactivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Inactivo';

    UPDATE dbo.TB_direccion_envio
    SET
        id_estado = @IdEstadoInactivo,
        es_principal = 0
    WHERE id_direccion = @IdDireccion
      AND id_usuario = @IdUsuario;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No se encontró la dirección.' AS Mensaje;

        RETURN;
    END;

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'La dirección fue desactivada correctamente.' AS Mensaje;
END;
GO

   /* ============================================================
CONSULTAR ROLES
   ============================================================ */

   CREATE OR ALTER PROCEDURE dbo.SP_ConsultarRoles
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_rol AS IdRol,
        nombre_rol AS NombreRol
    FROM dbo.TB_rol
    ORDER BY nombre_rol;
END;
GO

   /* ============================================================
CONSULTAR ESTADOS GENERAL
   ============================================================ */
CREATE OR ALTER PROCEDURE dbo.SP_ConsultarEstados
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_estado AS IdEstado,
        nombre_estado AS NombreEstado
    FROM dbo.TB_estado
    ORDER BY nombre_estado;
END;
GO

   /* ============================================================
CONSULTAR PROVINCIAS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarProvincias
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_provincia AS IdProvincia,
        nombre_provincia AS NombreProvincia
    FROM dbo.TB_provincia
    ORDER BY nombre_provincia;
END;
GO

   /* ============================================================
CONSULTAR CANTONES POR PROVINCIA
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarCantonesPorProvincia
    @IdProvincia INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_canton AS IdCanton,
        nombre_canton AS NombreCanton
    FROM dbo.TB_canton
    WHERE id_provincia = @IdProvincia
    ORDER BY nombre_canton;
END;
GO

   /* ============================================================
CONSULTAR DISTRITOS POR CANTON
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarDistritosPorCanton
    @IdCanton INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_distrito AS IdDistrito,
        nombre_distrito AS NombreDistrito
    FROM dbo.TB_distrito
    WHERE id_canton = @IdCanton
    ORDER BY nombre_distrito;
END;
GO

   /* ============================================================
CONSULTAR ESTADOS DE USUARIO
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarEstadosUsuario
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id_estado AS IdEstado,
        nombre_estado AS NombreEstado
    FROM dbo.TB_estado
    WHERE nombre_estado IN (N'Activo', N'Inactivo')
    ORDER BY
        CASE nombre_estado
            WHEN N'Activo' THEN 1
            WHEN N'Inactivo' THEN 2
            ELSE 3
        END;
END;
GO


   /* ============================================================
SP REGISTRAR USUARIO
   ============================================================ */


CREATE OR ALTER PROCEDURE dbo.SP_RegistrarUsuario
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Cedula NVARCHAR(20) = NULL,
    @Telefono NVARCHAR(20) = NULL,
    @Email NVARCHAR(150),
    @Contrasenna NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdRolCliente INT;
    DECLARE @IdEstadoActivo INT;

    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Apellido = LTRIM(RTRIM(@Apellido));
    SET @Cedula = NULLIF(LTRIM(RTRIM(@Cedula)), '');
    SET @Telefono = NULLIF(LTRIM(RTRIM(@Telefono)), '');
    SET @Email = LOWER(LTRIM(RTRIM(@Email)));

    SELECT @IdRolCliente = id_rol
    FROM dbo.TB_rol
    WHERE nombre_rol = N'Cliente';

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    IF @IdRolCliente IS NULL
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No se encontró el rol Cliente.' AS Mensaje,
            CAST(NULL AS INT) AS IdUsuario;

        RETURN;
    END;

    IF @IdEstadoActivo IS NULL
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No se encontró el estado Activo.' AS Mensaje,
            CAST(NULL AS INT) AS IdUsuario;

        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.TB_usuario
        WHERE LOWER(email) = @Email
    )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El correo electrónico ya está registrado.' AS Mensaje,
            CAST(NULL AS INT) AS IdUsuario;

        RETURN;
    END;

    IF @Cedula IS NOT NULL
       AND EXISTS
       (
           SELECT 1
           FROM dbo.TB_usuario
           WHERE cedula = @Cedula
       )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'La cédula ya está registrada.' AS Mensaje,
            CAST(NULL AS INT) AS IdUsuario;

        RETURN;
    END;

    INSERT INTO dbo.TB_usuario
    (
        nombre,
        apellido,
        cedula,
        telefono,
        email,
        contrasena,
        id_rol,
        id_estado
    )
    VALUES
    (
        @Nombre,
        @Apellido,
        @Cedula,
        @Telefono,
        @Email,
        @Contrasenna,
        @IdRolCliente,
        @IdEstadoActivo
    );

    DECLARE @IdUsuario INT = SCOPE_IDENTITY();

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'La cuenta fue creada correctamente.' AS Mensaje,
        @IdUsuario AS IdUsuario;
END;
GO

   /* ============================================================
    CONSULTAR USUARIO RECUPERACION
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarUsuarioRecuperacion
    @Email NVARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

    SET @Email = LOWER(LTRIM(RTRIM(@Email)));

    SELECT
        U.id_usuario AS IdUsuario,
        U.nombre AS Nombre,
        U.apellido AS Apellido,
        U.email AS Email
    FROM dbo.TB_usuario AS U
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = U.id_estado
    WHERE LOWER(U.email) = @Email
      AND E.nombre_estado = N'Activo';
END;
GO


   /* ============================================================
    GUARDAR CONTRASENA TEMPORAL
   ============================================================ */

   CREATE OR ALTER PROCEDURE dbo.SP_ActualizarContrasennaTemporal
    @IdUsuario INT,
    @Contrasenna NVARCHAR(255),
    @VigenciaContrasennaTemporal DATETIME2(0)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.TB_usuario
    SET
        contrasena = @Contrasenna,
        tiene_contrasenna_temporal = 1,
        vigencia_contrasenna_temporal =
            @VigenciaContrasennaTemporal
    WHERE id_usuario = @IdUsuario;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No fue posible actualizar la contraseña.' AS Mensaje;

        RETURN;
    END;

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'La contraseña temporal fue generada.' AS Mensaje;
END;
GO

   /* ============================================================
    CONTRASENA TEMPORAL
   ============================================================ */

IF COL_LENGTH(
    'dbo.TB_usuario',
    'tiene_contrasenna_temporal'
) IS NULL
BEGIN
    ALTER TABLE dbo.TB_usuario
    ADD tiene_contrasenna_temporal BIT NOT NULL
        CONSTRAINT DF_TB_usuario_contrasenna_temporal
        DEFAULT 0;
END;
GO

IF COL_LENGTH(
    'dbo.TB_usuario',
    'vigencia_contrasenna_temporal'
) IS NULL
BEGIN
    ALTER TABLE dbo.TB_usuario
    ADD vigencia_contrasenna_temporal DATETIME2(0) NULL;
END;
GO

   /* ============================================================
   USUARIO ADMINISTRADOR
   ============================================================ */


DECLARE @IdRolAdministrador INT;
DECLARE @IdEstadoActivo INT;

SELECT @IdRolAdministrador = id_rol
FROM dbo.TB_rol
WHERE nombre_rol = N'Administrador';

SELECT @IdEstadoActivo = id_estado
FROM dbo.TB_estado
WHERE nombre_estado = N'Activo';

INSERT INTO dbo.TB_usuario
(
    nombre,
    apellido,
    cedula,
    telefono,
    email,
    contrasena,
    id_rol,
    id_estado
)
VALUES
(
    N'Edgardo',
    N'Solano',
    N'116610961',
    N'60429113',
    N'edgardoasolano@gmail.com',
    N'$2a$11$n6aiATDsdic4zn6xXD3SBeM6.m8TycSVXRBO6xajYcJBGgjMt3yc',
    @IdRolAdministrador,
    @IdEstadoActivo
);
GO

SELECT
    U.id_usuario,
    U.nombre,
    U.apellido,
    U.email,
    R.nombre_rol,
    E.nombre_estado
FROM dbo.TB_usuario U
INNER JOIN dbo.TB_rol R
    ON R.id_rol = U.id_rol
INNER JOIN dbo.TB_estado E
    ON E.id_estado = U.id_estado
WHERE U.email = N'edgardoasolano@gmail.com';

GO

  /* ============================================================
  CONSULTAR USUARIOS GENERAL
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarUsuarios
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        U.id_usuario AS IdUsuario,
        U.nombre AS Nombre,
        U.apellido AS Apellido,
        U.cedula AS Cedula,
        U.telefono AS Telefono,
        U.email AS Email,
        U.id_rol AS IdRol,
        R.nombre_rol AS NombreRol,
        U.id_estado AS IdEstado,
        E.nombre_estado AS NombreEstado,
        U.fecha_registro AS FechaRegistro
    FROM dbo.TB_usuario AS U
    INNER JOIN dbo.TB_rol AS R
        ON R.id_rol = U.id_rol
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = U.id_estado
    ORDER BY
        U.fecha_registro DESC,
        U.nombre ASC,
        U.apellido ASC;
END;
GO

  /* ============================================================
  CONSULTAR USUARIOS GENERAL
   ============================================================ */
  
CREATE OR ALTER PROCEDURE dbo.SP_RegistrarUsuarioAdministracion
    @Nombre NVARCHAR(100),
    @Apellido NVARCHAR(100),
    @Cedula NVARCHAR(30) = NULL,
    @Telefono NVARCHAR(30) = NULL,
    @Email NVARCHAR(150),
    @Contrasenna NVARCHAR(255),
    @IdRol INT,
    @IdEstado INT
AS
BEGIN
    SET NOCOUNT ON;

    SET @Nombre = LTRIM(RTRIM(@Nombre));
    SET @Apellido = LTRIM(RTRIM(@Apellido));
    SET @Cedula = NULLIF(LTRIM(RTRIM(@Cedula)), '');
    SET @Telefono = NULLIF(LTRIM(RTRIM(@Telefono)), '');
    SET @Email = LOWER(LTRIM(RTRIM(@Email)));

    IF @Nombre IS NULL OR @Nombre = ''
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El nombre es obligatorio.' AS Mensaje;

        RETURN;
    END;

    IF @Apellido IS NULL OR @Apellido = ''
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El apellido es obligatorio.' AS Mensaje;

        RETURN;
    END;

    IF @Email IS NULL OR @Email = ''
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El correo electrónico es obligatorio.' AS Mensaje;

        RETURN;
    END;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.TB_usuario
        WHERE LOWER(LTRIM(RTRIM(email))) = @Email
    )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El correo electrónico ya está registrado.' AS Mensaje;

        RETURN;
    END;

    IF @Cedula IS NOT NULL
       AND EXISTS
       (
           SELECT 1
           FROM dbo.TB_usuario
           WHERE LTRIM(RTRIM(cedula)) = @Cedula
       )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'La cédula ya está registrada.' AS Mensaje;

        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.TB_rol
        WHERE id_rol = @IdRol
    )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El rol seleccionado no es válido.' AS Mensaje;

        RETURN;
    END;

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.TB_estado
        WHERE id_estado = @IdEstado
    )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El estado seleccionado no es válido.' AS Mensaje;

        RETURN;
    END;

    INSERT INTO dbo.TB_usuario
    (
        nombre,
        apellido,
        cedula,
        telefono,
        email,
        contrasena,
        id_rol,
        id_estado,
        fecha_registro,
        tiene_contrasenna_temporal,
        vigencia_contrasenna_temporal
    )
    VALUES
    (
        @Nombre,
        @Apellido,
        @Cedula,
        @Telefono,
        @Email,
        @Contrasenna,
        @IdRol,
        @IdEstado,
        GETDATE(),
        0,
        NULL
    );

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'El usuario fue registrado correctamente.' AS Mensaje;
END;
GO



   /* ============================================================
    Carrito
   OBTENER O CREAR CARRITO ACTIVO (RF-04)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ObtenerOCrearCarritoActivo
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdEstadoActivo INT;
    DECLARE @IdCarrito INT;

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    BEGIN TRANSACTION;

    SELECT TOP (1) @IdCarrito = id_carrito
    FROM dbo.TB_carrito WITH (UPDLOCK, HOLDLOCK)
    WHERE id_usuario = @IdUsuario
      AND id_estado = @IdEstadoActivo
    ORDER BY id_carrito;

    IF @IdCarrito IS NULL
    BEGIN
        INSERT INTO dbo.TB_carrito (id_usuario, id_estado)
        VALUES (@IdUsuario, @IdEstadoActivo);

        SET @IdCarrito = SCOPE_IDENTITY();
    END;

    COMMIT TRANSACTION;

    SELECT @IdCarrito AS IdCarrito;
END;
GO

   /* ============================================================
   Carrito
   AGREGAR PRODUCTO AL CARRITO (RF-04)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_AgregarProductoCarrito
    @IdUsuario INT,
    @IdProducto INT,
    @Cantidad INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'La cantidad debe ser mayor que cero.' AS Mensaje,
            CAST(NULL AS INT) AS CantidadItems;
        RETURN;
    END;

    DECLARE @IdEstadoActivo INT;
    DECLARE @IdEstadoDisponible INT;
    DECLARE @Stock INT;
    DECLARE @IdCarrito INT;
    DECLARE @CantidadActual INT;

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    SELECT @IdEstadoDisponible = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Disponible';

    SELECT @Stock = stock
    FROM dbo.TB_producto
    WHERE id_producto = @IdProducto
      AND id_estado = @IdEstadoDisponible;

    IF @Stock IS NULL
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El producto no está disponible.' AS Mensaje,
            CAST(NULL AS INT) AS CantidadItems;
        RETURN;
    END;

    BEGIN TRANSACTION;

    SELECT TOP (1) @IdCarrito = id_carrito
    FROM dbo.TB_carrito WITH (UPDLOCK, HOLDLOCK)
    WHERE id_usuario = @IdUsuario
      AND id_estado = @IdEstadoActivo
    ORDER BY id_carrito;

    IF @IdCarrito IS NULL
    BEGIN
        INSERT INTO dbo.TB_carrito (id_usuario, id_estado)
        VALUES (@IdUsuario, @IdEstadoActivo);

        SET @IdCarrito = SCOPE_IDENTITY();
    END;

    SELECT @CantidadActual = cantidad
    FROM dbo.TB_detalle_carrito
    WHERE id_carrito = @IdCarrito
      AND id_producto = @IdProducto;

    IF ISNULL(@CantidadActual, 0) + @Cantidad > @Stock
    BEGIN
        ROLLBACK TRANSACTION;

        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No hay stock suficiente. Disponible: '
                + CAST(@Stock - ISNULL(@CantidadActual, 0) AS NVARCHAR(10))
                + N' unidad(es).' AS Mensaje,
            CAST(NULL AS INT) AS CantidadItems;
        RETURN;
    END;

    IF @CantidadActual IS NULL
    BEGIN
        INSERT INTO dbo.TB_detalle_carrito (id_carrito, id_producto, cantidad)
        VALUES (@IdCarrito, @IdProducto, @Cantidad);
    END
    ELSE
    BEGIN
        UPDATE dbo.TB_detalle_carrito
        SET cantidad = cantidad + @Cantidad
        WHERE id_carrito = @IdCarrito
          AND id_producto = @IdProducto;
    END;

    COMMIT TRANSACTION;

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'El producto fue agregado al carrito.' AS Mensaje,
        (
            SELECT ISNULL(SUM(cantidad), 0)
            FROM dbo.TB_detalle_carrito
            WHERE id_carrito = @IdCarrito
        ) AS CantidadItems;
END;
GO

   /* ============================================================
   Carrito
   ACTUALIZAR CANTIDAD EN EL CARRITO (RF-04)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ActualizarCantidadCarrito
    @IdUsuario INT,
    @IdProducto INT,
    @Cantidad INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoActivo INT;
    DECLARE @IdEstadoDisponible INT;
    DECLARE @IdCarrito INT;
    DECLARE @Stock INT;

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    SELECT @IdEstadoDisponible = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Disponible';

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
             AND id_producto = @IdProducto
       )
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El producto no está en el carrito.' AS Mensaje;
        RETURN;
    END;

    IF @Cantidad IS NULL OR @Cantidad <= 0
    BEGIN
        DELETE FROM dbo.TB_detalle_carrito
        WHERE id_carrito = @IdCarrito
          AND id_producto = @IdProducto;

        SELECT
            CAST(1 AS BIT) AS Exitoso,
            N'El producto fue eliminado del carrito.' AS Mensaje;
        RETURN;
    END;

    SELECT @Stock = stock
    FROM dbo.TB_producto
    WHERE id_producto = @IdProducto
      AND id_estado = @IdEstadoDisponible;

    IF @Stock IS NULL
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El producto no está disponible.' AS Mensaje;
        RETURN;
    END;

    IF @Cantidad > @Stock
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'No hay stock suficiente. Disponible: '
                + CAST(@Stock AS NVARCHAR(10))
                + N' unidad(es).' AS Mensaje;
        RETURN;
    END;

    UPDATE dbo.TB_detalle_carrito
    SET cantidad = @Cantidad
    WHERE id_carrito = @IdCarrito
      AND id_producto = @IdProducto;

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'La cantidad fue actualizada.' AS Mensaje;
END;
GO

   /* ============================================================
   Carrito
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_EliminarProductoCarrito
    @IdUsuario INT,
    @IdProducto INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoActivo INT;
    DECLARE @IdCarrito INT;

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    SELECT TOP (1) @IdCarrito = id_carrito
    FROM dbo.TB_carrito
    WHERE id_usuario = @IdUsuario
      AND id_estado = @IdEstadoActivo
    ORDER BY id_carrito;

    DELETE FROM dbo.TB_detalle_carrito
    WHERE id_carrito = @IdCarrito
      AND id_producto = @IdProducto;

    IF @@ROWCOUNT = 0
    BEGIN
        SELECT
            CAST(0 AS BIT) AS Exitoso,
            N'El producto no está en el carrito.' AS Mensaje;
        RETURN;
    END;

    SELECT
        CAST(1 AS BIT) AS Exitoso,
        N'El producto fue eliminado del carrito.' AS Mensaje;
END;
GO

   /* ============================================================
   Carrito
   CONSULTAR CARRITO (RF-04)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarCarrito
    @IdUsuario INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoActivo INT;
    DECLARE @IdEstadoDisponible INT;

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    SELECT @IdEstadoDisponible = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Disponible';

    SELECT
        C.id_carrito AS IdCarrito,
        P.id_producto AS IdProducto,
        P.nombre_producto AS NombreProducto,
        IMG.ruta_imagen AS RutaImagen,
        P.precio AS PrecioUnitario,
        DC.cantidad AS Cantidad,
        CONVERT(DECIMAL(10,2), P.precio * DC.cantidad) AS SubtotalLinea,
        P.stock AS StockDisponible,
        P.es_pieza_unica AS EsPiezaUnica,
        CAST(CASE
                WHEN P.id_estado = @IdEstadoDisponible
                     AND P.stock >= DC.cantidad THEN 1
                ELSE 0
             END AS BIT) AS Disponible
    FROM dbo.TB_carrito AS C
    INNER JOIN dbo.TB_detalle_carrito AS DC
        ON DC.id_carrito = C.id_carrito
    INNER JOIN dbo.TB_producto AS P
        ON P.id_producto = DC.id_producto
    LEFT JOIN dbo.TB_imagen_producto AS IMG
        ON IMG.id_producto = P.id_producto
       AND IMG.es_principal = 1
    WHERE C.id_usuario = @IdUsuario
      AND C.id_estado = @IdEstadoActivo
    ORDER BY P.nombre_producto;
END;
GO

   /* ============================================================
   Carrito
   CONSULTAR RESUMEN DE CHECKOUT (RF-05)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarResumenCheckout
    @IdUsuario INT,
    @IdDireccion INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IdEstadoActivo INT;
    DECLARE @IdEstadoDisponible INT;

    SELECT @IdEstadoActivo = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Activo';

    SELECT @IdEstadoDisponible = id_estado
    FROM dbo.TB_estado
    WHERE nombre_estado = N'Disponible';

    SELECT
        C.id_carrito AS IdCarrito,
        P.id_producto AS IdProducto,
        P.nombre_producto AS NombreProducto,
        IMG.ruta_imagen AS RutaImagen,
        P.precio AS PrecioUnitario,
        DC.cantidad AS Cantidad,
        CONVERT(DECIMAL(10,2), P.precio * DC.cantidad) AS SubtotalLinea,
        P.stock AS StockDisponible,
        CAST(CASE
                WHEN P.id_estado = @IdEstadoDisponible
                     AND P.stock >= DC.cantidad THEN 1
                ELSE 0
             END AS BIT) AS Disponible
    FROM dbo.TB_carrito AS C
    INNER JOIN dbo.TB_detalle_carrito AS DC
        ON DC.id_carrito = C.id_carrito
    INNER JOIN dbo.TB_producto AS P
        ON P.id_producto = DC.id_producto
    LEFT JOIN dbo.TB_imagen_producto AS IMG
        ON IMG.id_producto = P.id_producto
       AND IMG.es_principal = 1
    WHERE C.id_usuario = @IdUsuario
      AND C.id_estado = @IdEstadoActivo
      AND EXISTS
      (
          SELECT 1
          FROM dbo.TB_direccion_envio AS DE
          WHERE DE.id_direccion = @IdDireccion
            AND DE.id_usuario = @IdUsuario
            AND DE.id_estado = @IdEstadoActivo
      )
    ORDER BY P.nombre_producto;
END;
GO

   /* ============================================================
   Carrito
   CONSULTAR MÉTODOS DE PAGO ACTIVOS (RF-05)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarMetodosPago
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        MP.id_metodo_pago AS IdMetodoPago,
        MP.nombre_metodo AS NombreMetodo
    FROM dbo.TB_metodo_pago AS MP
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = MP.id_estado
    WHERE E.nombre_estado = N'Activo'
    ORDER BY MP.nombre_metodo;
END;
GO

   /* ============================================================
    Carrito
   CONFIRMAR COMPRA (RF-05 + RF-08)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConfirmarCompra
    @IdUsuario INT,
    @IdDireccion INT,
    @IdMetodoPago INT,
    @CostoEnvio DECIMAL(10,2)
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

        /* Pago simulado: comprobante generado por el sistema. */
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
            N'SIM-' + RIGHT(N'000000' + CAST(@IdPedido AS NVARCHAR(10)), 6),
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
    Carrito
   CONSULTAR CONFIRMACIÓN DE PEDIDO (RF-08)
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

   /* ============================================================
   Carrito
   CONSULTAR HISTORIAL DE PEDIDOS (RF-09)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarHistorialPedidos
    @IdUsuario INT,
    @Pagina INT,
    @TamanoPagina INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Pagina IS NULL OR @Pagina < 1
    BEGIN
        SET @Pagina = 1;
    END;

    IF @TamanoPagina IS NULL OR @TamanoPagina < 1
    BEGIN
        SET @TamanoPagina = 10;
    END;

    SELECT
        PE.id_pedido AS IdPedido,
        F.numero_factura AS NumeroFactura,
        PE.fecha_pedido AS FechaPedido,
        PE.total AS Total,
        E.nombre_estado AS NombreEstado,
        CASE E.nombre_estado
            WHEN N'Pagado' THEN N'Comprada'
            WHEN N'En preparación' THEN N'En camino'
            WHEN N'Entregado' THEN N'Recibido'
            ELSE E.nombre_estado
        END AS EstadoVisible,
        (
            SELECT ISNULL(SUM(DP.cantidad), 0)
            FROM dbo.TB_detalle_pedido AS DP
            WHERE DP.id_pedido = PE.id_pedido
        ) AS CantidadProductos,
        COUNT(*) OVER () AS TotalFilas
    FROM dbo.TB_pedido AS PE
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = PE.id_estado
    LEFT JOIN dbo.TB_factura AS F
        ON F.id_pedido = PE.id_pedido
    WHERE PE.id_usuario = @IdUsuario
    ORDER BY PE.fecha_pedido DESC, PE.id_pedido DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO

   /* ============================================================
    Carrito
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarDetallePedido
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
        PG.fecha_pago AS FechaPago,
        MP.nombre_metodo AS NombreMetodoPago,
        EP.nombre_estado AS EstadoPago,
        DE.nombre_destinatario AS NombreDestinatario,
        DE.telefono_contacto AS TelefonoContacto,
        DE.direccion_exacta AS DireccionExacta,
        DE.referencia AS Referencia,
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
    LEFT JOIN dbo.TB_estado AS EP
        ON EP.id_estado = PG.id_estado
    LEFT JOIN dbo.TB_imagen_producto AS IMG
        ON IMG.id_producto = P.id_producto
       AND IMG.es_principal = 1
    WHERE PE.id_pedido = @IdPedido
      AND PE.id_usuario = @IdUsuario
    ORDER BY P.nombre_producto;
END;
GO

   /* ============================================================
   Carrito
   DATOS DE PRUEBA DEL MÓDULO CARRITO/CHECKOUT
   ============================================================ */

DECLARE @IdEstadoActivo INT;
DECLARE @IdEstadoDisponible INT;
DECLARE @IdEstadoAgotado INT;

SELECT @IdEstadoActivo = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Activo';
SELECT @IdEstadoDisponible = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Disponible';
SELECT @IdEstadoAgotado = id_estado FROM dbo.TB_estado WHERE nombre_estado = N'Agotado';

INSERT INTO dbo.TB_categoria (nombre_categoria, descripcion, id_estado)
SELECT C.nombre_categoria, C.descripcion, @IdEstadoActivo
FROM (VALUES
    (N'Collares', N'Collares artesanales'),
    (N'Pulseras', N'Pulseras artesanales'),
    (N'Llaveros', N'Llaveros artesanales')
) AS C (nombre_categoria, descripcion)
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.TB_categoria AS X
    WHERE X.nombre_categoria = C.nombre_categoria
);

INSERT INTO dbo.TB_producto
(nombre_producto, descripcion, precio, stock, es_pieza_unica, destacado, id_categoria, id_estado)
SELECT
    P.nombre_producto,
    P.descripcion,
    P.precio,
    P.stock,
    P.es_pieza_unica,
    P.destacado,
    CAT.id_categoria,
    CASE WHEN P.agotado = 1 THEN @IdEstadoAgotado ELSE @IdEstadoDisponible END
FROM (VALUES
    (N'Collar Bello',      N'Collar artesanal con dije',        CAST(8500.00 AS DECIMAL(10,2)), 10, 0, 1, N'Collares', 0),
    (N'Collar Pato',       N'Collar artesanal con dije de pato', CAST(7000.00 AS DECIMAL(10,2)),  5, 0, 0, N'Collares', 0),
    (N'Pulsera de Perlas', N'Pulsera de perlas hecha a mano',    CAST(5500.00 AS DECIMAL(10,2)),  8, 0, 1, N'Pulseras', 0),
    (N'Pulsera Clásica',   N'Pulsera artesanal pieza única',     CAST(4500.00 AS DECIMAL(10,2)),  1, 1, 0, N'Pulseras', 0),
    (N'Llavero Flor',      N'Llavero artesanal con flor',        CAST(2500.00 AS DECIMAL(10,2)),  0, 0, 0, N'Llaveros', 1)
) AS P (nombre_producto, descripcion, precio, stock, es_pieza_unica, destacado, nombre_categoria, agotado)
INNER JOIN dbo.TB_categoria AS CAT
    ON CAT.nombre_categoria = P.nombre_categoria
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.TB_producto AS X
    WHERE X.nombre_producto = P.nombre_producto
);

INSERT INTO dbo.TB_imagen_producto (id_producto, ruta_imagen, es_principal, id_estado)
SELECT PROD.id_producto, I.ruta_imagen, 1, @IdEstadoActivo
FROM (VALUES
    (N'Collar Bello',      N'Content/Images/collarbello.jpeg'),
    (N'Collar Pato',       N'Content/Images/collarpato.jpeg'),
    (N'Pulsera de Perlas', N'Content/Images/perlas.jpeg'),
    (N'Pulsera Clásica',   N'Content/Images/pulsera.jpeg'),
    (N'Llavero Flor',      N'Content/Images/llaveroflor.jpeg')
) AS I (nombre_producto, ruta_imagen)
INNER JOIN dbo.TB_producto AS PROD
    ON PROD.nombre_producto = I.nombre_producto
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.TB_imagen_producto AS X
    WHERE X.id_producto = PROD.id_producto
      AND X.es_principal = 1
);
GO

   /* ============================================================
   CONSULTAR PRODUCTOS DESTACADOS (portada)
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_ConsultarProductosDestacados
    @Top INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @Top IS NULL OR @Top < 1
    BEGIN
        SET @Top = 4;
    END;

    SELECT TOP (@Top)
        P.id_producto AS IdProducto,
        P.nombre_producto AS NombreProducto,
        P.precio AS Precio,
        IMG.ruta_imagen AS RutaImagen,
        C.nombre_categoria AS NombreCategoria
    FROM dbo.TB_producto AS P
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = P.id_estado
    INNER JOIN dbo.TB_categoria AS C
        ON C.id_categoria = P.id_categoria
    LEFT JOIN dbo.TB_imagen_producto AS IMG
        ON IMG.id_producto = P.id_producto
       AND IMG.es_principal = 1
    WHERE P.destacado = 1
      AND E.nombre_estado = N'Disponible'
    ORDER BY P.fecha_creacion DESC, P.id_producto DESC;
END;

/* ============================================================
   DASHBOARD CONSULTAR RESUMEN
   ============================================================ */

GO

CREATE OR ALTER PROCEDURE dbo.SP_Dashboard_ConsultarResumen
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        CAST(
            ISNULL(
                (
                    SELECT SUM(PE.total)
                    FROM dbo.TB_pedido AS PE
                    INNER JOIN dbo.TB_estado AS E
                        ON E.id_estado = PE.id_estado
                    WHERE E.nombre_estado IN
                    (
                        N'Pagado',
                        N'En preparación',
                        N'Entregado'
                    )
                ),
                0
            )
            AS DECIMAL(18,2)
        ) AS TotalVentas,

        (
            SELECT COUNT(*)
            FROM dbo.TB_pedido
            WHERE id_estado IN
            (
                SELECT id_estado
                FROM dbo.TB_estado
                WHERE nombre_estado IN
                (
                    N'Pendiente',
                    N'Pagado',
                    N'En preparación',
                    N'Entregado'
                )
            )
        ) AS TotalPedidos,

        (
            SELECT COUNT(*)
            FROM dbo.TB_usuario AS U
            INNER JOIN dbo.TB_rol AS R
                ON R.id_rol = U.id_rol
            INNER JOIN dbo.TB_estado AS E
                ON E.id_estado = U.id_estado
            WHERE R.nombre_rol = N'Cliente'
              AND E.nombre_estado = N'Activo'
        ) AS TotalClientesActivos,

        (
            SELECT COUNT(*)
            FROM dbo.TB_producto AS P
            INNER JOIN dbo.TB_estado AS E
                ON E.id_estado = P.id_estado
            WHERE P.stock = 0
               OR E.nombre_estado = N'Agotado'
        ) AS TotalProductosAgotados;
END;
GO



   /* ============================================================
   DASHBOARD CONSULTAR VENTAS MENSUALES
   ============================================================ */

   USE BD_LEN;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Dashboard_ConsultarVentasMensuales
    @Anno INT
AS
BEGIN
    SET NOCOUNT ON;

    ;WITH Meses AS
    (
        SELECT 1 AS NumeroMes, N'Ene' AS NombreMes
        UNION ALL
        SELECT 2, N'Feb'
        UNION ALL
        SELECT 3, N'Mar'
        UNION ALL
        SELECT 4, N'Abr'
        UNION ALL
        SELECT 5, N'May'
        UNION ALL
        SELECT 6, N'Jun'
        UNION ALL
        SELECT 7, N'Jul'
        UNION ALL
        SELECT 8, N'Ago'
        UNION ALL
        SELECT 9, N'Sep'
        UNION ALL
        SELECT 10, N'Oct'
        UNION ALL
        SELECT 11, N'Nov'
        UNION ALL
        SELECT 12, N'Dic'
    ),
    Ventas AS
    (
        SELECT
            MONTH(PE.fecha_pedido) AS NumeroMes,
            SUM(PE.total) AS TotalVentas
        FROM dbo.TB_pedido AS PE
        INNER JOIN dbo.TB_estado AS E
            ON E.id_estado = PE.id_estado
        WHERE YEAR(PE.fecha_pedido) = @Anno
          AND E.nombre_estado IN
          (
              N'Pagado',
              N'En preparación',
              N'Entregado'
          )
        GROUP BY
            MONTH(PE.fecha_pedido)
    )
    SELECT
        M.NumeroMes,
        M.NombreMes,
        CAST(
            ISNULL(V.TotalVentas, 0)
            AS DECIMAL(18,2)
        ) AS TotalVentas
    FROM Meses AS M
    LEFT JOIN Ventas AS V
        ON V.NumeroMes = M.NumeroMes
    ORDER BY
        M.NumeroMes;
END;
GO




   /* ============================================================
   DASHBOARD CONSULTAR ACTIVIDADES RECIENTES
   ============================================================ */

   USE BD_LEN;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Dashboard_ConsultarActividadReciente
    @Cantidad INT = 5
AS
BEGIN
    SET NOCOUNT ON;

    IF @Cantidad IS NULL OR @Cantidad < 1
    BEGIN
        SET @Cantidad = 5;
    END;

    SELECT TOP (@Cantidad)
        PE.id_pedido AS IdPedido,

        CONCAT(
            N'Pedido #',
            PE.id_pedido
        ) AS Titulo,

        CONCAT(
            U.nombre,
            N' ',
            U.apellido,
            N' realizó un pedido por ₡',
            CONVERT(
                NVARCHAR(30),
                CAST(PE.total AS DECIMAL(18,2))
            )
        ) AS Descripcion,

        PE.fecha_pedido AS Fecha,

        E.nombre_estado AS Tipo
    FROM dbo.TB_pedido AS PE
    INNER JOIN dbo.TB_usuario AS U
        ON U.id_usuario = PE.id_usuario
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = PE.id_estado
    ORDER BY
        PE.fecha_pedido DESC,
        PE.id_pedido DESC;
END;
GO

 /* ============================================================
   DASHBOARD CONSULTAS GENERALES PRUEBAS
   ============================================================ */

   USE BD_LEN;
GO

DECLARE @AnnoActual INT = YEAR(GETDATE());

EXEC dbo.SP_Dashboard_ConsultarResumen;
GO

DECLARE @AnnoActual INT = YEAR(GETDATE());

EXEC dbo.SP_Dashboard_ConsultarVentasMensuales
    @Anno = @AnnoActual;
GO

EXEC dbo.SP_Dashboard_ConsultarActividadReciente
    @Cantidad = 5;
GO

   /* ============================================================
   ADMINISTRACIÓN DE FACTURAS (RF-14 apoyo)
   ============================================================ */

   USE BD_LEN;
GO

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarFacturas
    @Busqueda NVARCHAR(150) = NULL,
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
        F.id_factura        AS IdFactura,
        F.id_pedido         AS IdPedido,
        F.numero_factura    AS NumeroFactura,
        F.fecha_factura     AS FechaFactura,
        F.subtotal          AS Subtotal,
        F.costo_envio       AS CostoEnvio,
        F.total             AS Total,
        E.nombre_estado     AS NombreEstado,
        U.nombre + N' ' + U.apellido AS NombreCliente,
        U.email             AS EmailCliente,
        MP.nombre_metodo    AS MetodoPago,
        PA.comprobante      AS Comprobante,
        COUNT(*) OVER ()    AS TotalFilas
    FROM dbo.TB_factura AS F
    INNER JOIN dbo.TB_pedido AS PE ON PE.id_pedido = F.id_pedido
    INNER JOIN dbo.TB_usuario AS U ON U.id_usuario = PE.id_usuario
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = F.id_estado
    LEFT JOIN dbo.TB_pago AS PA ON PA.id_pedido = F.id_pedido
    LEFT JOIN dbo.TB_metodo_pago AS MP ON MP.id_metodo_pago = PA.id_metodo_pago
    WHERE (@Busqueda IS NULL OR @Busqueda = N''
           OR F.numero_factura LIKE N'%' + @Busqueda + N'%'
           OR U.nombre + N' ' + U.apellido LIKE N'%' + @Busqueda + N'%'
           OR U.email LIKE N'%' + @Busqueda + N'%')
      AND (@FechaInicio IS NULL OR F.fecha_factura >= @FechaInicio)
      AND (@FechaFin IS NULL OR F.fecha_factura < DATEADD(DAY, 1, @FechaFin))
    ORDER BY F.fecha_factura DESC, F.id_factura DESC
    OFFSET (@Pagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO


CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarDetalleFactura
    @IdFactura INT
AS
BEGIN
    SET NOCOUNT ON;

    /*
       Devuelve una fila por producto con el encabezado repetido,
       siguiendo la convención del resto de SPs de detalle del
       proyecto (un solo result set, consumible con SqlQuery).
    */
    SELECT
        F.id_factura        AS IdFactura,
        F.id_pedido         AS IdPedido,
        F.numero_factura    AS NumeroFactura,
        F.fecha_factura     AS FechaFactura,
        F.subtotal          AS Subtotal,
        F.costo_envio       AS CostoEnvio,
        F.total             AS Total,
        E.nombre_estado     AS NombreEstado,
        U.nombre + N' ' + U.apellido AS NombreCliente,
        U.email             AS EmailCliente,
        U.telefono          AS TelefonoCliente,
        D.direccion_exacta  AS DireccionExacta,
        PR.nombre_provincia AS Provincia,
        CA.nombre_canton    AS Canton,
        DI.nombre_distrito  AS Distrito,
        MP.nombre_metodo    AS MetodoPago,
        PA.comprobante      AS Comprobante,
        PA.fecha_pago       AS FechaPago,
        P.nombre_producto   AS NombreProducto,
        DP.cantidad         AS Cantidad,
        DP.precio_unitario  AS PrecioUnitario,
        DP.subtotal_linea   AS SubtotalLinea
    FROM dbo.TB_factura AS F
    INNER JOIN dbo.TB_pedido AS PE ON PE.id_pedido = F.id_pedido
    INNER JOIN dbo.TB_usuario AS U ON U.id_usuario = PE.id_usuario
    INNER JOIN dbo.TB_estado AS E ON E.id_estado = F.id_estado
    INNER JOIN dbo.TB_detalle_pedido AS DP ON DP.id_pedido = F.id_pedido
    INNER JOIN dbo.TB_producto AS P ON P.id_producto = DP.id_producto
    LEFT JOIN dbo.TB_direccion_envio AS D ON D.id_direccion = PE.id_direccion
    LEFT JOIN dbo.TB_distrito AS DI ON DI.id_distrito = D.id_distrito
    LEFT JOIN dbo.TB_canton AS CA ON CA.id_canton = DI.id_canton
    LEFT JOIN dbo.TB_provincia AS PR ON PR.id_provincia = CA.id_provincia
    LEFT JOIN dbo.TB_pago AS PA ON PA.id_pedido = F.id_pedido
    LEFT JOIN dbo.TB_metodo_pago AS MP ON MP.id_metodo_pago = PA.id_metodo_pago
    WHERE F.id_factura = @IdFactura
    ORDER BY P.nombre_producto;
END;
GO


 /* ============================================================
   CONSULTAR PAGOS
   ============================================================ */

CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarPagos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        PG.id_pago AS IdPago,
        PG.id_pedido AS IdPedido,

        CONCAT(
            U.nombre,
            N' ',
            U.apellido
        ) AS NombreCliente,

        U.email AS EmailCliente,

        MP.nombre_metodo AS NombreMetodoPago,

        PG.monto AS Monto,

        PG.fecha_pago AS FechaPago,

        PG.comprobante AS Comprobante,

        E.nombre_estado AS NombreEstado

    FROM dbo.TB_pago AS PG

    INNER JOIN dbo.TB_pedido AS PE
        ON PE.id_pedido = PG.id_pedido

    INNER JOIN dbo.TB_usuario AS U
        ON U.id_usuario = PE.id_usuario

    INNER JOIN dbo.TB_metodo_pago AS MP
        ON MP.id_metodo_pago = PG.id_metodo_pago

    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = PG.id_estado

    ORDER BY
        PG.fecha_pago DESC,
        PG.id_pago DESC;
END;
GO


 /* ============================================================
   CONSULTAR RESUMEN DE PAGOS
   ============================================================ */


CREATE OR ALTER PROCEDURE dbo.SP_Admin_ConsultarResumenPagos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT

        (
            SELECT COUNT(*)
            FROM dbo.TB_pago
        ) AS TotalPagos,

        CAST(
            ISNULL(
                (
                    SELECT SUM(monto)
                    FROM dbo.TB_pago
                ),
                0
            )
            AS DECIMAL(18,2)
        ) AS TotalRecaudado,

        (
            SELECT COUNT(*)
            FROM dbo.TB_pago
            WHERE CAST(fecha_pago AS DATE)
                = CAST(GETDATE() AS DATE)
        ) AS PagosHoy,

        CAST(
            ISNULL(
                (
                    SELECT SUM(monto)
                    FROM dbo.TB_pago
                    WHERE CAST(fecha_pago AS DATE)
                        = CAST(GETDATE() AS DATE)
                ),
                0
            )
            AS DECIMAL(18,2)
        ) AS RecaudadoHoy;
END;
GO