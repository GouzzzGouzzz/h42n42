open%client Eliom_content.Html.D
open%client Eliom_content.Html.Manip
open%client Js_of_ocaml_lwt

type%client creet = {
  mutable x : float;
  mutable y : float;
  mutable dir_x : float;
  mutable dir_y : float;
}

let%client () = Random.self_init ()

(* Elements *)

let%client get_area_size main_area () =
  let dom = Eliom_content.Html.To_dom.of_element main_area in
  (dom##.clientWidth, dom##.clientHeight)


(* Creet specific *)

let%client create_creet main_area() =
  let creet_html = div ~a:[a_class ["creet"]; ] [] in
  let (area_x, area_y) = get_area_size main_area () in
  let angle = Random.float (2. *. Float.pi) in
    (
      {
        x = float (area_x/2 - 10);
        y = float (area_y/2 - 10);
        dir_x = cos angle;
        dir_y = sin angle;
      },
      creet_html)

let%client rec creet_movement creet creet_html main_area =
  (* Direction *)
  creet.x <- creet.x +. creet.dir_x *. 1.;
  creet.y <- creet.y +. creet.dir_y *. 1.;
  (* Apply to css *)
  let creet_dom = Eliom_content.Html.To_dom.of_element creet_html in
  creet_dom##.style##.left := Js_of_ocaml.Js.string (string_of_float creet.x ^ "px");
  creet_dom##.style##.top  := Js_of_ocaml.Js.string (string_of_float creet.y ^ "px");
  (* Stay in bound *)
  let (area_x, area_y) = get_area_size main_area () in
  if creet.x < 0. || creet.x > float (area_x - 20) then creet.dir_x <- -. creet.dir_x;
  if creet.y < 0. || creet.y > float (area_y - 20) then creet.dir_y <- -. creet.dir_y;
  let%lwt () = Lwt_js.sleep 0.01 in
  creet_movement creet creet_html main_area

let%client add_creet main_area () =
  let (creet, creet_html) = create_creet main_area () in
  appendChild main_area creet_html;
  Lwt.async (fun () -> creet_movement creet creet_html main_area)

let%client rec spawn_interval main_area () =
  add_creet main_area ();
  let%lwt () = Lwt_js.sleep 5.0 in
  spawn_interval main_area ()



