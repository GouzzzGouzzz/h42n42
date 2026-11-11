open%client Eliom_content.Html.D
open%client Eliom_content.Html.Manip
open%client Js_of_ocaml_lwt
open%client Js_of_ocaml

type%client creetStatus =
  | Healthy
  | Sick
  | Mean
  | Berserk


type%client creetType = {
  mutable x : float;
  mutable y : float;
  mutable dir_x : float;
  mutable dir_y : float;
  mutable speed : float;
  mutable status : creetStatus;
  mutable is_dragged : bool;
  mutable size : int;
  mutable random_dir_timer : float;
  mutable html : [ `Div ] Eliom_content.Html.elt;
}


(* Some constant settings *)
let%client () = Random.self_init ()
let%client random_dir_interval = 7.5
let%client random_dir_chance = 0.5
let%client random_contaminate_chance = 0.02

let%client refresh_rate = 1. /. 60.

(* Global value *)

let%client selected_creet = ref None
let%client creet_drag_offset = ref (0., 0.)

let%client creets : creetType list ref = ref []


let%client get_random_dir () =
  let angle = Random.float (2. *. Float.pi) in
  (cos angle, sin angle)

let%client create_creet main_area () =
  let creet_html = div ~a:[a_class ["creet"]; ] [] in
  (* Might need to remember this instead of calling every frame *)
  let (area_x, area_y) = Zone.get_area_size main_area () in
  let (dir_x, dir_y) = get_random_dir () in
  (
    {
    x = float (area_x/2 - 10);
    y = float (area_y/2 - 10);
    dir_x = dir_x;
    dir_y = dir_y;
    speed = 3.;
    status = Healthy;
    is_dragged = false;
    size = 30;
    random_dir_timer = Random.float 10.;
    html = creet_html;
    })

let%client be_sick creet () =
  let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
  creet_dom##.classList##add (Js.string "creet-sick");
  creet.status <- Sick;
  creet.speed <- creet.speed *. 0.85

let%client be_healthy creet () =
  let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
  creet_dom##.classList##remove (Js.string "creet-sick");
  creet.status <- Healthy;
  creet.speed <- 3.;
  Js_of_ocaml.Console.console##log (Js.string "dropped hospital")


let%client is_in_river creet () =
  let river = Dom_html.getElementById "river" in
  let (area_x, area_y) = Zone.get_area_size river () in
  if
    creet.y < float area_y
    && creet.y +. float creet.size > 0.
    && creet.x +. float creet.size > 0.
    && creet.x < float area_x
  then true else false

let%client is_in_hospital creet () =
  let hospital = Dom_html.getElementById "hospital" in
  let main_area = Dom_html.getElementById "main-area" in
  let (_, hospital_y) = Zone.get_area_size hospital () in
  let (area_x, area_y) = Zone.get_area_size main_area () in
  if
    creet.y +. float creet.size > float (area_y - hospital_y)
    && creet.y < float area_y
    && creet.x +. float creet.size > 0.
    && creet.x < float area_x
  then true else false

let%client rec creet_movement creet main_area =
  if not creet.is_dragged then begin
    (* Direction *)
    creet.x <- creet.x +. creet.dir_x *. creet.speed;
    creet.y <- creet.y +. creet.dir_y *. creet.speed;

    (* Stay in bound *)
    let (area_x, area_y) = Zone.get_area_size main_area () in

    (* angle of incidence equals angle of reflection, reversing the corresponding vector basically*)
    if creet.x < 0. then creet.dir_x <- Float.abs creet.dir_x;
    if creet.x > float (area_x - creet.size) then creet.dir_x <- -. Float.abs creet.dir_x;
    if creet.y < 0. then creet.dir_y <- Float.abs creet.dir_y;
    if creet.y > float (area_y - creet.size) then creet.dir_y <- -. Float.abs creet.dir_y;

    (* Apply to css *)
    let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
    creet_dom##.style##.left := Js_of_ocaml.Js.string (string_of_float creet.x ^ "px");
    creet_dom##.style##.top := Js_of_ocaml.Js.string (string_of_float creet.y ^ "px");

    (* If in river then be sick *)
    if is_in_river creet () && creet.status = Healthy then be_sick creet ();

    (* Contamination *)
    if creet.status <> Healthy then (
      List.iter (fun other_creet ->
          if other_creet != creet && other_creet.status = Healthy && not other_creet.is_dragged then (
            (* https://www.jeffreythompson.org/collision-detection/circle-circle.php *)
            let dx = other_creet.x -. creet.x in
            let dy = other_creet.y -. creet.y in
            let dist = sqrt (dx *. dx +. dy *. dy) in
            if dist <= (float creet.size) then (
              if Random.float 1. < random_contaminate_chance then (
                be_sick other_creet ();
              )
            )
          )
        ) !creets;
      );

    (* Random move *)
    creet.random_dir_timer <- creet.random_dir_timer +. refresh_rate;
    if creet.random_dir_timer > random_dir_interval then (
      creet.random_dir_timer <- 0.;
      if Random.float 1. < random_dir_chance then (
        let (dir_x, dir_y) = get_random_dir () in
        creet.dir_x <- dir_x;
        creet.dir_y <- dir_y;
      )
    );
  end;
  let%lwt () = Lwt_js.sleep refresh_rate in
  creet_movement creet main_area

let%client add_creet () =
  let main_area = Dom_html.getElementById "main-area" in
  let creet = create_creet main_area () in
  creets := creet :: !creets;
  appendChild (Eliom_content.Html.Of_dom.of_element main_area) creet.html;

  (* Handling drag and drop *)
  (* MOUSE DOWNS *)
  Lwt.async (fun () -> Js_of_ocaml_lwt.Lwt_js_events.mousedowns
    (Eliom_content.Html.To_dom.of_element creet.html)
    (fun ev _ ->
      Dom.preventDefault ev;
      (match !selected_creet with
      | None ->
        (* Keep offset to avoid the creet teleporting to the mouse *)
        let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
        let rect = creet_dom##getBoundingClientRect in
        let offset_x = Js.float_of_number ev##.clientX -. Js.float_of_number rect##.left in
        let offset_y = Js.float_of_number ev##.clientY -. Js.float_of_number rect##.top in

        creet.is_dragged <- true;
        selected_creet := Some creet;
        creet_drag_offset := (offset_x, offset_y)

      | Some _ -> ()
      );
      Lwt.return ())
    );

  (* Create a thread for one creet *)
  Lwt.async (fun () -> creet_movement creet main_area )

let%client rec spawn_interval () =
  let%lwt () = Lwt_js.sleep 5.00 in
  if List.exists (fun creet -> creet.status = Healthy) !creets then add_creet ();
  spawn_interval ()

let%client init_listeners () =
  (* Init eventListener of document to handle drag and drop *)
  (* Move the creet *)
  (* MOUSE MOVES *)
  Lwt.async (fun () -> Js_of_ocaml_lwt.Lwt_js_events.mousemoves
    (Dom_html.document)
    (fun ev _ ->
      Dom.preventDefault ev;
      (match !selected_creet with
        | Some creet ->
          let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
          let main_area = Dom_html.getElementById "main-area" in
          let rect = main_area##getBoundingClientRect in
          let offset_x, offset_y = !creet_drag_offset in
          let mouse_x = Js.float_of_number ev##.clientX -. Js.float_of_number rect##.left -. offset_x in
          let mouse_y = Js.float_of_number ev##.clientY -. Js.float_of_number rect##.top -. offset_y in

          creet_dom##.style##.left := Js_of_ocaml.Js.string (string_of_float mouse_x ^ "px");
          creet_dom##.style##.top := Js_of_ocaml.Js.string (string_of_float mouse_y ^ "px");
          creet.x <- mouse_x;
          creet.y <- mouse_y;
        | None -> ()
      );
      Lwt.return ())
    );

    (* Put it back on his "feet" *)
    (* MOUSE UPS *)
    Lwt.async (fun () -> Js_of_ocaml_lwt.Lwt_js_events.mouseups
    (Dom_html.document)
    (fun ev _ ->
      Dom.preventDefault ev;
      (match !selected_creet with
        | Some creet ->
          creet.is_dragged <- false;
          selected_creet := None;

          (* If dropped in hospital *)
          if creet.status = Sick then (
            if is_in_hospital creet () then be_healthy creet ();
          )
        | None -> ()
      );
      Lwt.return ())
    );
