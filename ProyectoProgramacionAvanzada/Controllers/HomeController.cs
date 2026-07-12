using ProyectoProgramacionAvanzada.EF;
using ProyectoProgramacionAvanzada.Models;
using ProyectoProgramacionAvanzada.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace ProyectoProgramacionAvanzada.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            return View();
        }


        [HttpGet]
        public ActionResult Login()
        {
            if (Session["IdUsuario"] != null)
            {
                return RedirectToAction("Index", "Home");
            }

            return View(new InicioSesionModel());
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Login(InicioSesionModel Modelo)
        {
            if (!ModelState.IsValid)
            {
                return View(Modelo);
            }

            using (var Servicio = new UsuarioService())
            {
                SP_ConsultarUsuarioInicioSesion_Result Usuario =
                    Servicio.ValidarCredenciales(Modelo);

                if (Usuario == null)
                {
                    ModelState.AddModelError(
                        string.Empty,
                        "El correo o la contraseña son incorrectos, o el usuario no esta activo."
                    );

                    return View(Modelo);
                }

                Session["IdUsuario"] = Usuario.IdUsuario;
                Session["NombreUsuario"] =
                    Usuario.Nombre + " " + Usuario.Apellido;
                Session["IdRol"] = Usuario.IdRol;
                Session["NombreRol"] = Usuario.NombreRol;
                Session["IdEstado"] = Usuario.IdEstado;
                Session["NombreEstado"] = Usuario.NombreEstado;

                return RedirectToAction("Index", "Home");
            }
        }


        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }

        public ActionResult ForgotPassword()
        {
            ViewBag.Message = "Recuperar Acceso a la cuenta.";

            return View();
        }
    }
}