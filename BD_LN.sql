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
        E.nombre_estado AS NombreEstado
    FROM dbo.TB_usuario AS U
    INNER JOIN dbo.TB_rol AS R
        ON R.id_rol = U.id_rol
    INNER JOIN dbo.TB_estado AS E
        ON E.id_estado = U.id_estado
    WHERE U.email = LTRIM(RTRIM(@Email));
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


SELECT * FROM TB_direccion_envio