using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Services
{
    public class UsuarioService : IDisposable
    {
        private readonly BD_LENEntities Contexto;

        public UsuarioService()
        {
            Contexto = new BD_LENEntities();
        }

        public SP_ConsultarUsuarioInicioSesion_Result ValidarCredenciales(
        InicioSesionModel Modelo)
        {
            string EmailNormalizado = Modelo.Email.Trim();

            SP_ConsultarUsuarioInicioSesion_Result Usuario = Contexto
                .SP_ConsultarUsuarioInicioSesion(EmailNormalizado)
                .FirstOrDefault();

            if (Usuario == null)
            {
                return null;
            }

            if (!string.Equals(
                Usuario.NombreEstado,
                "Activo",
                StringComparison.OrdinalIgnoreCase))
            {
                return null;
            }

            // Validar que la contraseña temporal no esté vencida
           if (Usuario.TieneContrasennaTemporal == true)
            {
                if (!Usuario.VigenciaContrasennaTemporal.HasValue ||
                    Usuario.VigenciaContrasennaTemporal.Value < DateTime.Now)
                {
                    return null;
                }
            }

            bool ContrasennaValida = BCrypt.Net.BCrypt.Verify(
                Modelo.Contrasenna,
                Usuario.Contrasenna
            );

            if (!ContrasennaValida)
            {
                return null;
            }

            return Usuario;
        }

        public UsuarioModel ConsultarUsuarioPorId(int IdUsuario)
        {
            SP_ConsultarUsuarioPorId_Result Resultado = Contexto
                .SP_ConsultarUsuarioPorId(IdUsuario)
                .FirstOrDefault();

            if (Resultado == null)
            {
                return null;
            }

            return new UsuarioModel
            {
                IdUsuario = Resultado.IdUsuario,
                Nombre = Resultado.Nombre,
                Apellido = Resultado.Apellido,
                Cedula = Resultado.Cedula,
                Telefono = Resultado.Telefono,
                Email = Resultado.Email,
                IdRol = Resultado.IdRol,
                NombreRol = Resultado.NombreRol,
                IdEstado = Resultado.IdEstado,
                NombreEstado = Resultado.NombreEstado,
                FechaRegistro = Resultado.FechaRegistro
            };
        }

        public string ActualizarUsuario(UsuarioModel Modelo)
        {
            SP_ActualizarUsuario_Result Resultado = Contexto
                .SP_ActualizarUsuario(
                    Modelo.IdUsuario,
                    Modelo.Nombre,
                    Modelo.Apellido,
                    Modelo.Cedula,
                    Modelo.Telefono,
                    Modelo.Email,
                    Modelo.IdRol,
                    Modelo.IdEstado
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return "No fue posible actualizar el usuario.";
            }

            return Resultado.Mensaje;
        }

        public string RestablecerContrasenna(UsuarioModel Modelo)
        {
            string HashContrasenna = BCrypt.Net.BCrypt.HashPassword(
                Modelo.Contrasenna
            );

            SP_RestablecerContrasennaUsuario_Result Resultado = Contexto
                .SP_RestablecerContrasennaUsuario(
                    Modelo.IdUsuario,
                    HashContrasenna
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return "No fue posible restablecer la contraseña.";
            }

            return Resultado.Mensaje;
        }

        public List<DireccionModel> ConsultarDirecciones(
            int IdUsuario)
        {
            return Contexto
                .SP_ConsultarDireccionesUsuario(IdUsuario)
                .Select(Direccion => new DireccionModel
                {
                    IdDireccion = Direccion.IdDireccion,
                    IdUsuario = Direccion.IdUsuario,
                    IdProvincia = Direccion.IdProvincia,
                    NombreProvincia = Direccion.NombreProvincia,
                    IdCanton = Direccion.IdCanton,
                    NombreCanton = Direccion.NombreCanton,
                    IdDistrito = Direccion.IdDistrito,
                    NombreDistrito = Direccion.NombreDistrito,
                    DireccionExacta = Direccion.DireccionExacta,
                    Referencia = Direccion.Referencia,
                    TelefonoContacto = Direccion.TelefonoContacto,
                    NombreDestinatario = Direccion.NombreDestinatario,
                    EsPrincipal = Direccion.EsPrincipal,
                    IdEstado = Direccion.IdEstado,
                    NombreEstado = Direccion.NombreEstado
                })
                .ToList();
        }

        public DireccionModel ConsultarDireccionPorId(
            int IdDireccion,
            int IdUsuario)
        {
            SP_ConsultarDireccionPorId_Result Direccion = Contexto
                .SP_ConsultarDireccionPorId(
                    IdDireccion,
                    IdUsuario
                )
                .FirstOrDefault();

            if (Direccion == null)
            {
                return null;
            }

            return new DireccionModel
            {
                IdDireccion = Direccion.IdDireccion,
                IdUsuario = Direccion.IdUsuario,
                IdProvincia = Direccion.IdProvincia,
                NombreProvincia = Direccion.NombreProvincia,
                IdCanton = Direccion.IdCanton,
                NombreCanton = Direccion.NombreCanton,
                IdDistrito = Direccion.IdDistrito,
                NombreDistrito = Direccion.NombreDistrito,
                DireccionExacta = Direccion.DireccionExacta,
                Referencia = Direccion.Referencia,
                TelefonoContacto = Direccion.TelefonoContacto,
                NombreDestinatario = Direccion.NombreDestinatario,
                EsPrincipal = Direccion.EsPrincipal,
                IdEstado = Direccion.IdEstado,
                NombreEstado = Direccion.NombreEstado
            };
        }

        public string InsertarDireccion(DireccionModel Modelo)
        {
            SP_InsertarDireccionUsuario_Result Resultado = Contexto
                .SP_InsertarDireccionUsuario(
                    Modelo.IdUsuario,
                    Modelo.IdDistrito,
                    Modelo.DireccionExacta,
                    Modelo.Referencia,
                    Modelo.TelefonoContacto,
                    Modelo.NombreDestinatario,
                    Modelo.EsPrincipal
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return "No fue posible agregar la dirección.";
            }

            return Resultado.Mensaje;
        }

        public string ActualizarDireccion(DireccionModel Modelo)
        {
            SP_ActualizarDireccionUsuario_Result Resultado = Contexto
                .SP_ActualizarDireccionUsuario(
                    Modelo.IdDireccion,
                    Modelo.IdUsuario,
                    Modelo.IdDistrito,
                    Modelo.DireccionExacta,
                    Modelo.Referencia,
                    Modelo.TelefonoContacto,
                    Modelo.NombreDestinatario,
                    Modelo.EsPrincipal
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return "No fue posible actualizar la dirección.";
            }

            return Resultado.Mensaje;
        }

        public string DesactivarDireccion(
            int IdDireccion,
            int IdUsuario)
        {
            SP_DesactivarDireccionUsuario_Result Resultado = Contexto
                .SP_DesactivarDireccionUsuario(
                    IdDireccion,
                    IdUsuario
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return "No fue posible desactivar la dirección.";
            }

            return Resultado.Mensaje;
        }

        public List<SelectListItem> ConsultarRoles()
        {
            return Contexto
                .SP_ConsultarRoles()
                .Select(Rol => new SelectListItem
                {
                    Value = Rol.IdRol.ToString(),
                    Text = Rol.NombreRol
                })
                .ToList();
        }

        public List<SelectListItem> ConsultarEstados()
        {
            return Contexto
                .SP_ConsultarEstadosUsuario()
                .Select(Estado => new SelectListItem
                {
                    Value = Estado.IdEstado.ToString(),
                    Text = Estado.NombreEstado
                })
                .ToList();
        }

        public List<SelectListItem> ConsultarProvincias()
        {
            return Contexto
                .SP_ConsultarProvincias()
                .Select(Provincia => new SelectListItem
                {
                    Value = Provincia.IdProvincia.ToString(),
                    Text = Provincia.NombreProvincia
                })
                .ToList();
        }

        public object ConsultarCantonesPorProvincia(
            int IdProvincia)
        {
            return Contexto
                .SP_ConsultarCantonesPorProvincia(IdProvincia)
                .Select(Canton => new
                {
                    IdCanton = Canton.IdCanton,
                    NombreCanton = Canton.NombreCanton
                })
                .ToList();
        }

        public object ConsultarDistritosPorCanton(
            int IdCanton)
        {
            return Contexto
                .SP_ConsultarDistritosPorCanton(IdCanton)
                .Select(Distrito => new
                {
                    IdDistrito = Distrito.IdDistrito,
                    NombreDistrito = Distrito.NombreDistrito
                })
                .ToList();
        }


        public string RegistrarUsuario(UsuarioModel Modelo)
        {
            string HashContrasenna =
                BCrypt.Net.BCrypt.HashPassword(Modelo.Contrasenna);

            SP_RegistrarUsuario_Result Resultado = Contexto
                .SP_RegistrarUsuario(
                    Modelo.Nombre,
                    Modelo.Apellido,
                    Modelo.Cedula,
                    Modelo.Telefono,
                    Modelo.Email,
                    HashContrasenna
                )
                .FirstOrDefault();

            if (Resultado == null)
            {
                return "No fue posible registrar el usuario.";
            }

            if (Resultado.Exitoso != true)
            {
                throw new InvalidOperationException(
                    Resultado.Mensaje
                );
            }

            return Resultado.Mensaje;
        }

        public SP_ConsultarUsuarioRecuperacion_Result
    ConsultarUsuarioRecuperacion(string Email)
        {
            string EmailNormalizado =
                Email.Trim().ToLower();

            return Contexto
                .SP_ConsultarUsuarioRecuperacion(
                    EmailNormalizado
                )
                .FirstOrDefault();
        }


        public string ActualizarContrasennaTemporal(
    int IdUsuario,
    string ContrasennaTemporal,
    DateTime Vigencia)
        {
            string HashContrasenna =
                BCrypt.Net.BCrypt.HashPassword(
                    ContrasennaTemporal
                );

            SP_ActualizarContrasennaTemporal_Result Resultado =
                Contexto
                    .SP_ActualizarContrasennaTemporal(
                        IdUsuario,
                        HashContrasenna,
                        Vigencia
                    )
                    .FirstOrDefault();

            if (Resultado == null)
            {
                throw new InvalidOperationException(
                    "No fue posible generar la contraseña temporal."
                );
            }

            if (Resultado.Exitoso != true)
            {
                throw new InvalidOperationException(
                    Resultado.Mensaje
                );
            }

            return Resultado.Mensaje;
        }


        public string GenerarContrasennaTemporal()
        {
            const string Caracteres =
                "ABCDEFGHJKLMNPQRSTUVWXYZ" +
                "abcdefghijkmnopqrstuvwxyz" +
                "23456789" +
                "!@$%";

            byte[] Valores = new byte[10];

            using (
                var Generador =
                    System.Security.Cryptography
                        .RandomNumberGenerator.Create()
            )
            {
                Generador.GetBytes(Valores);
            }

            char[] Resultado = new char[Valores.Length];

            for (int Indice = 0;
                 Indice < Valores.Length;
                 Indice++)
            {
                Resultado[Indice] =
                    Caracteres[
                        Valores[Indice] %
                        Caracteres.Length
                    ];
            }

            return new string(Resultado);
        }
        public void Dispose()
        {
            Contexto.Dispose();
        }
    }
}