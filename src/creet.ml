open Eliom_content.Html.D

let creet_html = div ~a:[a_class ["creet"]; ] []

type creet = {
  mutable x : int;
  mutable y : int;
  mutable dir_x : int;
  mutable dir_y : int;
}


let spawn_creet () =
  creet_html


