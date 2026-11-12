open%server Eliom_content.Html.D

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
    let _ = [%client
      (Creet.init_listeners ());
      (Lwt.async (fun () -> Creet.accelerate_speed ()));
      (Lwt.async (fun () -> Creet.spawn_interval ()) : unit)
      ] in
    let _ = [%client (
      Creet.add_creet ();
      Creet.add_creet ();
      Creet.add_creet ();
      Creet.add_creet ();
      Creet.add_creet () : unit)]
    in
      Lwt.return
        (html
          (head (title (txt "H42N42")) [
            css_link ~uri:(make_uri ~service:(Eliom_service.static_dir ()) ["area.css"]) ()
          ])
          (body [
            Zone.main_area
          ]))
        )

