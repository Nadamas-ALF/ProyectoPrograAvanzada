using System;
using System.Configuration;
using System.Net;
using System.Net.Mail;

namespace ProyectoProgramacionAvanzada.Services
{
    public class CorreoService
    {
        public void EnviarCorreo(
            string Destinatario,
            string Asunto,
            string ContenidoHtml)
        {
            string CorreoSalida =
                ConfigurationManager.AppSettings[
                    "CorreoSalida"
                ];

            string ContrasennaCorreo =
                ConfigurationManager.AppSettings[
                    "ContrasennaCorreoSalida"
                ];

            string NombreCorreo =
                ConfigurationManager.AppSettings[
                    "NombreCorreoSalida"
                ];

            string ServidorCorreo =
                ConfigurationManager.AppSettings[
                    "ServidorCorreo"
                ];

            int PuertoCorreo = int.Parse(
                ConfigurationManager.AppSettings[
                    "PuertoCorreo"
                ]
            );

            bool UsarSsl = bool.Parse(
                ConfigurationManager.AppSettings[
                    "UsarSslCorreo"
                ]
            );

            if (string.IsNullOrWhiteSpace(CorreoSalida) ||
                string.IsNullOrWhiteSpace(ContrasennaCorreo))
            {
                throw new InvalidOperationException(
                    "La configuración del correo está incompleta."
                );
            }

            using (MailMessage Mensaje = new MailMessage())
            {
                Mensaje.From = new MailAddress(
                    CorreoSalida,
                    NombreCorreo
                );

                Mensaje.To.Add(Destinatario);
                Mensaje.Subject = Asunto;
                Mensaje.Body = ContenidoHtml;
                Mensaje.IsBodyHtml = true;

                using (SmtpClient Cliente = new SmtpClient())
                {
                    Cliente.Host = ServidorCorreo;
                    Cliente.Port = PuertoCorreo;
                    Cliente.EnableSsl = UsarSsl;
                    Cliente.UseDefaultCredentials = false;

                    Cliente.Credentials =
                        new NetworkCredential(
                            CorreoSalida,
                            ContrasennaCorreo
                        );

                    Cliente.Send(Mensaje);
                }
            }
        }
    }
}