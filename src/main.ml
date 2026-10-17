open Eliom_content.Html.D

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
      let main_area = div ~a:[a_class ["main-area"]; a_id "main-area"] [
        Zone.hospital_html;
        Zone.river_html;
      ] in
      let _ = [%client
        (Lwt.async (fun () -> Creet.spawn_interval ~%main_area ())
         : unit)
      ] in
      let _ = [%client (
        Creet.add_creet ~%main_area ();
        Creet.add_creet ~%main_area () : unit)]
      in
      Lwt.return
        (html
           (head (title (txt "H42N42")) [
              css_link ~uri:(make_uri ~service:(Eliom_service.static_dir ()) ["area.css"]) ()
            ])
           (body [
              main_area
           ]))
           )

