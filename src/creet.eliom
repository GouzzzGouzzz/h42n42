open%client Eliom_content.Html.D
open%client Eliom_content.Html.Manip
open%client Js_of_ocaml_lwt
open%client Js_of_ocaml

type%client 'a creetType = {
  mutable x : float;
  mutable y : float;
  mutable dir_x : float;
  mutable dir_y : float;
  mutable speed : float;
  mutable is_sick : bool;
  mutable is_dragged : bool;
  mutable size : int;
  mutable random_dir_timer : float;
  mutable html : 'a;
}

let%client random_dir_interval = 7.5
let%client random_dir_chance = 0.5

let%client refresh_rate = 1. /. 60.

let%client () = Random.self_init ()

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
    is_sick = false;
    is_dragged = false;
    size = 20;
    random_dir_timer = Random.float 10.;
    html = creet_html;
    })

let%client be_sick creet () =
  creet.is_sick <- true;
  creet.speed <- creet.speed *. 0.85;
  let dom = Eliom_content.Html.To_dom.of_element creet.html in
  dom##.classList##add (Js.string "creet-sick")

let%client is_in_river creet () =
  let river = Dom_html.getElementById "river" in
  let (_, area_y) = Zone.get_area_size river () in
  if creet.y < float area_y then true else false


let%client rec creet_movement creet main_area =
  if not creet.is_dragged then begin
    (* Direction *)
    creet.x <- creet.x +. creet.dir_x *. creet.speed;
    creet.y <- creet.y +. creet.dir_y *. creet.speed;

    (* Stay in bound *)
    let (area_x, area_y) = Zone.get_area_size main_area () in

    (* angle of incidence equals angle of reflection, reversing the corresponding vector basically*)
    if creet.x < 0. || creet.x > float (area_x - creet.size) then creet.dir_x <- -. creet.dir_x;
    if creet.y < 0. || creet.y > float (area_y - creet.size) then creet.dir_y <- -. creet.dir_y;

    (* Apply to css *)
    let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
    creet_dom##.style##.left := Js_of_ocaml.Js.string (string_of_float creet.x ^ "px");
    creet_dom##.style##.top := Js_of_ocaml.Js.string (string_of_float creet.y ^ "px");

    if is_in_river creet () && not creet.is_sick  then be_sick creet ();

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
  
  appendChild (Eliom_content.Html.Of_dom.of_element main_area) creet.html;

  (* Handling drag and drop *)
  Lwt.async (fun () -> Js_of_ocaml_lwt.Lwt_js_events.mousedowns
    (Eliom_content.Html.To_dom.of_element creet.html)
    (fun ev _ ->
      Dom.preventDefault ev;
      Js_of_ocaml.Console.console##log (Js.string "down");
      creet.is_dragged <- true;
      let creet_dom = Eliom_content.Html.To_dom.of_element creet.html in
      creet_dom##.classList##add (Js.string "creet-in-drag");
      Lwt.return ())
    );


  (* Create a thread for one creet *)
  Lwt.async (fun () -> creet_movement creet main_area )

let%client rec spawn_interval amount () =
  if amount < 50 then (
    add_creet ();
    let%lwt () = Lwt_js.sleep 0.10 in
    spawn_interval (amount + 1) ()
  ) else
    Lwt.return ()

    (* https://ocsigen.org/js_of_ocaml/latest/js_of_ocaml-lwt/Js_of_ocaml_lwt/Lwt_js_events/index.html *)


