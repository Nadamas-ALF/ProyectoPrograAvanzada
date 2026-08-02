using System;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.IO;

namespace ProyectoProgramacionAvanzada.Services
{

    public static class ImagenProductoService
    {

        public const int LadoMaximo = 1000;


        private const long CalidadJpeg = 90L;

        public static void GuardarNormalizada(
            Stream Origen,
            string RutaDestino)
        {
            if (Origen == null)
            {
                throw new ArgumentNullException("Origen");
            }

            if (Origen.CanSeek)
            {
                Origen.Position = 0;
            }

            using (Image Original = Image.FromStream(Origen))
            using (Bitmap Lienzo = CrearLienzo(Original))
            {
                Lienzo.SetResolution(96, 96);

                using (Graphics Dibujo = Graphics.FromImage(Lienzo))
                {
                    Dibujo.CompositingQuality = CompositingQuality.HighQuality;
                    Dibujo.InterpolationMode = InterpolationMode.HighQualityBicubic;
                    Dibujo.SmoothingMode = SmoothingMode.HighQuality;
                    Dibujo.PixelOffsetMode = PixelOffsetMode.HighQuality;


                    Dibujo.Clear(Color.White);

                    Rectangle Destino = CalcularDestinoCentrado(
                        Original.Width,
                        Original.Height,
                        Lienzo.Width
                    );

                    Dibujo.DrawImage(Original, Destino);
                }

                GuardarComoJpeg(Lienzo, RutaDestino);
            }
        }


        private static Bitmap CrearLienzo(Image Original)
        {
            int LadoMayor = Math.Max(Original.Width, Original.Height);

            int Lado = Math.Min(LadoMaximo, LadoMayor);

            if (Lado < 1)
            {
                Lado = 1;
            }

            return new Bitmap(Lado, Lado, PixelFormat.Format24bppRgb);
        }

        private static Rectangle CalcularDestinoCentrado(
            int AnchoOriginal,
            int AltoOriginal,
            int LadoLienzo)
        {
            if (AnchoOriginal <= 0 || AltoOriginal <= 0)
            {
                return new Rectangle(0, 0, LadoLienzo, LadoLienzo);
            }

            double Escala = Math.Min(
                (double)LadoLienzo / AnchoOriginal,
                (double)LadoLienzo / AltoOriginal
            );

            int Ancho = Math.Max(1, (int)Math.Round(AnchoOriginal * Escala));
            int Alto = Math.Max(1, (int)Math.Round(AltoOriginal * Escala));

            return new Rectangle(
                (LadoLienzo - Ancho) / 2,
                (LadoLienzo - Alto) / 2,
                Ancho,
                Alto
            );
        }

        private static void GuardarComoJpeg(
            Bitmap Imagen,
            string RutaDestino)
        {
            ImageCodecInfo Codificador = ObtenerCodificadorJpeg();

            if (Codificador == null)
            {
                Imagen.Save(RutaDestino, ImageFormat.Jpeg);
                return;
            }

            using (EncoderParameters Parametros = new EncoderParameters(1))
            {
                Parametros.Param[0] = new EncoderParameter(
                    Encoder.Quality,
                    CalidadJpeg
                );

                Imagen.Save(RutaDestino, Codificador, Parametros);
            }
        }

        private static ImageCodecInfo ObtenerCodificadorJpeg()
        {
            foreach (ImageCodecInfo Codec in ImageCodecInfo.GetImageEncoders())
            {
                if (Codec.FormatID == ImageFormat.Jpeg.Guid)
                {
                    return Codec;
                }
            }

            return null;
        }
    }
}
