library(shiny)

options(shiny.maxRequestSize = 30*1024^2)


generate_color_map <- function() {
  color_map <- rep("red", 50)
  names(color_map) <- sort(sample(1L:100, 50))
  color_map
}

viewer3dmolUI <- function(id) {
  ns <- NS(id)
  tagList(
    div(
      tags$button("Screenshot", id = ns("btn"), `data-screenshot` = ns("viewer")),
      tags$input(type = "checkbox", id = ns("spin"), checked = "checked", `data-spin` = ns("viewer")),
      tags$label(" Spin", `for` = ns("spin")),
      style = "margin-bottom: 10px;"
    ),
    div(id = ns("viewer"),
        `structure-viewer` = NA,
        style = "width:100%; height:400px; margin-bottom: 30px;")
  )
}

viewer3dmolServer <- function(id, fileReactive, color_map) {
  moduleServer(id, function(input, output, session) {
    observeEvent(fileReactive(), {
      file <- fileReactive()
      req(file)

      session$sendCustomMessage("renderStructure", list(
        containerId = session$ns("viewer"),
        data = paste(readLines(file$datapath), collapse = "\n"),
        colorMap = as.list(color_map),
        protName = tools::file_path_sans_ext(file$name)
      ))
    })
  })
}

ui <- fluidPage(
  tags$head(
    tags$script(src = "https://3Dmol.org/build/3Dmol-min.js")
  ),

  tags$style(HTML("
  #toolbar {
    margin: 10px 0;
    position: relative !important;
  }
  #btn-screenshot {
    font-size: 16px;
    padding: 8px 12px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
  #toggle-spin {
    cursor: pointer;
    margin-left: 20px;
    transform: scale(1.3);
    vertical-align: middle;
  }
  canvas {
    position: relative !important;
  }
")),

  titlePanel("ciezka praca"),

  sidebarLayout(
    sidebarPanel(
      fileInput("structureFile", "Upload a PDB/mmCIF file", accept = c(".cif", ".mmcif", ".pdb"))
    ),

    mainPanel(
      viewer3dmolUI("viewer1"),
      h3("Przerwa"),
      viewer3dmolUI("viewer2")
    )
  ),

  tags$script(src = "additional-scripts-3dmol.js")
)

server <- function(input, output, session) {
  file_reactive <- reactive(input[["structureFile"]])

  viewer3dmolServer("viewer1", fileReactive = file_reactive, color_map = generate_color_map())

  viewer3dmolServer("viewer2", fileReactive = file_reactive, color_map = generate_color_map())
}

shinyApp(ui, server)
