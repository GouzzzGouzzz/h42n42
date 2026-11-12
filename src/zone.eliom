open%server Eliom_content.Html.D

let%client get_area_size area () =
  (area##.clientWidth, area##.clientHeight)

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
