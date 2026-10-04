open Eliom_content.Html.D

module H42N42_app =
  Eliom_registration.App
    (struct
      let application_name = "h42n42"
      let global_data_path = None
    end)

let main_service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["home"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit)
    ()

let () =
  H42N42_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (html
           (head (title (txt "H42N42")) [])
           (body [
              div [
                (txt "Hello")
              ]

           ]))
           )