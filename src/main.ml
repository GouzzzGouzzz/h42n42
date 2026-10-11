open Eliom_content.Html.D
(* open%client Js_of_ocaml
open%client Js_of_ocaml_lwt
open%client Eliom_content.Html.To_dom *)



module H42N42_app =
  Eliom_registration.App
    (struct
      let application_name = "h42n42"
      let global_data_path = None
    end)

let main_service =
  Eliom_service.create
    ~path:(Eliom_service.Path [])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let () =
  H42N42_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (html
           (head (title (txt "H42N42")) [
              css_link ~uri:(make_uri ~service:(Eliom_service.static_dir ()) ["area.css"]) ()
            ])
           (body [
              div ~a:[a_class ["main-area"]] [
                Creet.creet_html;
                Zone.hospital_html;
                Zone.river_html;
              ];
           ]))
           )



