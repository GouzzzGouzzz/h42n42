open%client Eliom_content.Html.D
open%client Eliom_content.Html.Manip
open%client Js_of_ocaml_lwt

type%client creet = {
  mutable x : int;
  mutable y : int;
  mutable dir_x : int;
  mutable dir_y : int;
}


(* Elements *)

let%client get_area_size main_area () =
  let dom = Eliom_content.Html.To_dom.of_element main_area in
  (dom##.clientWidth, dom##.clientHeight)

(* Creet specific *)

let%client create_creet main_area() =
  let creet_html = div ~a:[a_class ["creet"]; ] [] in
  let (area_x, area_y) = get_area_size main_area () in
    ({ x = area_x/2 - 10; y = area_y/2 - 10; dir_x = 1; dir_y = 0 }, creet_html)

let%client rec creet_movement creet creet_html =
  creet.x <- creet.x + creet.dir_x;
  let creet_dom = Eliom_content.Html.To_dom.of_element creet_html in
  creet_dom##.style##.left := Js_of_ocaml.Js.string (string_of_int creet.x ^ "px");
  creet_dom##.style##.top  := Js_of_ocaml.Js.string (string_of_int creet.y ^ "px");
  let%lwt () = Lwt_js.sleep 0.05 in
  creet_movement creet creet_html

let%client add_creet main_area () =
  let (creet, creet_html) = create_creet main_area () in
  appendChild main_area creet_html;
  Lwt.async (fun () -> creet_movement creet creet_html)

let%client rec spawn_interval main_area () =
  add_creet main_area ();
  let%lwt () = Lwt_js.sleep 3.0 in
  spawn_interval main_area ()



