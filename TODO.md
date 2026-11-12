## Project

# I.2.1 Creet Movement and Behavior : Done

# VI.2.2 Player Interaction : Done

# VI.2.3 Contamination System Done

# VI.2.4 Hospital Healing : Done

# VI.2.5 Special Creet Types : Done

# VI.2.6 Difficulty Progression : Done

# VI.2.7 Game Over Condition : Done


V.1 Docker Requirements
Your project must include the following Docker configuration files:
•A Dockerfile that:
  ◦Uses an appropriate base image with OCaml support (e.g., ocaml/opam)
  ◦Installs all necessary dependencies (Ocsigen, Eliom, Js_of_ocaml, etc.)
  ◦Copies your source code into the container
  ◦Compiles your application
  ◦Exposes the appropriate port (default: 8080)
  ◦Defines the command to start the Ocsigen server
•A docker-compose.yml file that:
  ◦Defines the service for your application
  ◦Maps the container port to the host (e.g., 8080:8080)
  ◦Sets up any necessary volumes for development
  ◦Configures environment variables if needed

V.2 Deployment Instructions
Your application must be launchable with a single command:
docker-compose up --build

After running this command, the application should be accessible in a web browser
at http://localhost:8080 (or the port you specified).
The Docker setup must:
•Build successfully without manual intervention
•Install all dependencies automatically
•Compile the OCaml code to JavaScript using Js_of_ocaml
•Start the Ocsigen server automatically
•Serve the application on the specified port
•Handle server restarts gracefully during development (optional but recommended)

# VI.2.8 Implementation Guidelines

•Performance: Ensure smooth animation even with multiple Creets on screen.
Each Creet should run in its own Lwt thread.


Investigate on dragging not synchronized with the css

# To note

The game ends when there are no healthy or living Creets remaining

The game ends when all Creets are either dead or contaminated with no healthy
Creets remaining

