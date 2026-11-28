open%server Eliom_content.Html.D
open%client Js_of_ocaml

let%client main_area_size = ref (0, 0)
let%client river_size = ref (0, 0)
let%client hospital_size = ref (0, 0)


let%client get_area_size area () =
  (area##.clientWidth, area##.clientHeight)

let%client update_sizes () =
  let main_area = Dom_html.getElementById "main-area" in
  let river = Dom_html.getElementById "river" in
  let hospital = Dom_html.getElementById "hospital" in
  main_area_size := get_area_size main_area ();
  river_size := get_area_size river ();
  hospital_size := get_area_size hospital ()


let%server hospital_html = div ~a:[a_class ["hospital"]; a_id "hospital" ] []

let%server river_html = div ~a:[a_class ["river"]; a_id "river"] []

let%server game_over_html = div ~a:[a_class ["game-over"; "hidden"]; a_id "game-over"]
    [
      h1 [txt "GAME OVER"];
      p [txt "put these foolish ambitions to rest..."];
      p [txt "(press F5 to restart)"];
    ]

let%server main_area = div ~a:[a_class ["main-area"]; a_id "main-area"] [
    hospital_html;
    river_html;
    game_over_html;
  ]
