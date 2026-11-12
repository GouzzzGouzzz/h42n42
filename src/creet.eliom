open%client Eliom_content.Html.D
open%client Eliom_content.Html.Manip
open%client Js_of_ocaml_lwt
open%client Js_of_ocaml

type%client creetStatus =
  | Healthy
  | Sick
  | Mean
  | Berserk
  | Dead


type%client creetType = {
  mutable x : float;
  mutable y : float;
  mutable dir_x : float;
  mutable dir_y : float;
  mutable speed : float;
  mutable status : creetStatus;
  mutable is_dragged : bool;
  mutable size : float;
  mutable random_dir_timer : float;
  mutable evolve_timer : float;
  mutable death_timer : float;
  mutable has_target : bool;
  mutable html : [ `Div ] Eliom_content.Html.elt;
}


(* Some constant settings *)
let%client () = Random.self_init ()


(* Direction *)
let%client random_dir_interval = 7.5
let%client random_dir_chance = 0.5

(* Contamination settings *)
let%client random_contaminate_chance = 0.02
let%client evolve_interval = 10.0
let%client mean_thresh = 0.1
let%client berserk_thresh = 0.2

let%client refresh_rate = 1. /. 60.

(* Global value *)
let%client base_creet_size = 30.
let%client selected_creet = ref None
let%client creet_drag_offset = ref (0., 0.)
let%client creets : creetType list ref = ref []


let%client get_random_dir () =
  let angle = Random.float (2. *. Float.pi) in
  (cos angle, sin angle)

let%client create_creet main_area () =
  let creet_html = div ~a:[a_class ["creet"; "creet-healthy"]; ] [] in
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
    size = base_creet_size;
    random_dir_timer = Random.float 10.;
    evolve_timer = 0.;
    status_timer = 0.;
    death_timer = 0.;
    has_target = false;
    html = creet_html;
    })

let%client be_sick creet () =
  let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
  creet_dom##.classList##remove (Js.string "creet-healthy");
  creet_dom##.classList##add (Js.string "creet-sick");
  creet.status <- Sick;
  creet.speed <- creet.speed *. 0.85;
  creet.evolve_timer <- 0.

let%client be_healthy creet () =
  let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
  creet_dom##.classList##remove (Js.string "creet-sick");
  creet_dom##.classList##add (Js.string "creet-healthy");
  creet.status <- Healthy;
  creet.speed <- 3.

let%client be_dead creet () =
  creet.status <- Dead;
  removeSelf creet.html;
  creets := List.filter (fun c -> if c != creet then true else false) !creets

let%client be_berserk creet () =
  let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
  creet_dom##.classList##remove (Js.string "creet-sick");
  creet_dom##.classList##add (Js.string "creet-berserk");
  creet.status <- Berserk

let%client be_mean creet () =
  let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
  creet_dom##.classList##remove (Js.string "creet-sick");
  creet_dom##.classList##add (Js.string "creet-mean");
  creet.status <- Mean;
  creet.size <- creet.size *. 0.85

let%client is_in_river creet () =
  let river = Dom_html.getElementById "river" in
  let (area_x, area_y) = Zone.get_area_size river () in
  if
    creet.y < float area_y
    && creet.y +. creet.size > 0.
    && creet.x +. creet.size > 0.
    && creet.x < float area_x
  then true else false

let%client is_in_hospital creet () =
  let hospital = Dom_html.getElementById "hospital" in
  let main_area = Dom_html.getElementById "main-area" in
  let (_, hospital_y) = Zone.get_area_size hospital () in
  let (area_x, area_y) = Zone.get_area_size main_area () in
  if
    creet.y +. creet.size > float (area_y - hospital_y)
    && creet.y < float area_y
    && creet.x +. creet.size > 0.
    && creet.x < float area_x
  then true else false

let%client find_nearest_health creet () =
  List.fold_left (fun closest other ->
    if other.status <> Healthy || other.is_dragged then closest
    else
        let other_dx = other.x -. creet.x in
        let other_dy = other.y -. creet.y in
        let other_dist = other_dx *. other_dx +. other_dy *. other_dy in
        match closest with
        | None -> Some other
        | Some value ->
          let closest_dx = value.x -. creet.x in
          let closest_dy = value.y -. creet.y in
          let closest_dist = closest_dx *. closest_dx +. closest_dy *. closest_dy in
          if other_dist < closest_dist then Some other else closest
    ) None !creets

let%client chase_creet creet target () =
    let dx = target.x -. creet.x in
    let dy = target.y -. creet.y in
    let len = sqrt (dx *. dx +. dy *. dy) in
    if len > 0. then (
      creet.dir_x <- dx /. len;
      creet.dir_y <- dy /. len
    )

let%client rec creet_movement creet main_area () =
  if creet.status = Dead then Lwt.return ()
  else (
      if not creet.is_dragged then (
      (* Direction *)
      creet.x <- creet.x +. creet.dir_x *. creet.speed;
      creet.y <- creet.y +. creet.dir_y *. creet.speed;

      (* Stay in bound *)
      let (area_x, area_y) = Zone.get_area_size main_area () in

      (* angle of incidence equals angle of reflection, reversing the corresponding vector basically*)
      if creet.x < 0. then creet.dir_x <- Float.abs creet.dir_x;
      if creet.x > float area_x -. creet.size then creet.dir_x <- -. Float.abs creet.dir_x;
      if creet.y < 0. then creet.dir_y <- Float.abs creet.dir_y;
      if creet.y > float area_y -. creet.size then creet.dir_y <- -. Float.abs creet.dir_y;

      (* Apply to css *)
      let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
      creet_dom##.style##.left := Js_of_ocaml.Js.string (string_of_float creet.x ^ "px");
      creet_dom##.style##.top := Js_of_ocaml.Js.string (string_of_float creet.y ^ "px");
      creet_dom##.style##.width := Js.string (string_of_float creet.size ^ "px");
      creet_dom##.style##.height := Js.string (string_of_float creet.size ^ "px");

      (* Random move *)
      if not creet.has_target then (
        creet.random_dir_timer <- creet.random_dir_timer +. refresh_rate;
        if creet.random_dir_timer > random_dir_interval then (
          creet.random_dir_timer <- 0.;
          if Random.float 1. < random_dir_chance then (
            let (dir_x, dir_y) = get_random_dir () in
            creet.dir_x <- dir_x;
            creet.dir_y <- dir_y;
          )
        );
      );

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
              if dist <= creet.size then (
                if Random.float 1. < random_contaminate_chance then (
                  be_sick other_creet ();
                )
              )
            )
          ) !creets;
        );

      (* Be mean or berserk *)
      if creet.status = Sick then (
        creet.evolve_timer <- creet.evolve_timer +. refresh_rate;
        if creet.evolve_timer >= evolve_interval then (
          creet.evolve_timer <- creet.evolve_timer -. evolve_interval;
          let roll = Random.float 1. in
          if roll < mean_thresh then (
            be_mean creet ();
          )
          else if roll < berserk_thresh then (
            be_berserk creet ();
          );
        );
      );
      (* Mean handling *)
      if creet.status = Mean then (
        creet.death_timer <- creet.death_timer +. refresh_rate;
        (match find_nearest_health creet () with
        | None ->
          creet.has_target <- false;
        | Some target ->
          creet.has_target <- true;
          chase_creet creet target ();
        );
        if creet.death_timer > 60. then be_dead creet ();
      )
      (* Berserk handling *)
      else if creet.status = Berserk then (
        creet.death_timer <- creet.death_timer +. refresh_rate;
        if creet.death_timer > 10. then (
          creet.size <- creet.size *. 1.1;
          creet.death_timer <- creet.death_timer -. 10.;
          if creet.size >= 4. *. base_creet_size then be_dead creet ();
        )
      )
    );
    let%lwt () = Lwt_js.sleep refresh_rate in
    creet_movement creet main_area ()
  )

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
      (match !selected_creet, creet.status with
      | None, (Healthy | Sick) ->
        (* Keep offset to avoid the creet teleporting to the mouse *)
        let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
        let rect = creet_dom##getBoundingClientRect in
        let offset_x = Js.float_of_number ev##.clientX -. Js.float_of_number rect##.left in
        let offset_y = Js.float_of_number ev##.clientY -. Js.float_of_number rect##.top in

        creet.is_dragged <- true;
        selected_creet := Some creet;
        creet_drag_offset := (offset_x, offset_y)
      | _ -> ()
      );
      Lwt.return ())
    );

  (* Create a thread for one creet *)
  Lwt.async (fun () -> creet_movement creet main_area () )

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
