open%server Eliom_content.Html.D

let%client get_area_size area () =
  (area##.clientWidth, area##.clientHeight)

let%server hospital_html = div ~a:[a_class ["hospital"]; a_id "hospital" ] []

let%server river_html = div ~a:[a_class ["river"]; a_id "river"] []

let%server main_area = div ~a:[a_class ["main-area"]; a_id "main-area"] [
    hospital_html;
    river_html;
  ]
