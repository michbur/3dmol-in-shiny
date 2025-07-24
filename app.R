library(shiny)

options(shiny.maxRequestSize = 30*1024^2)

ui <- fluidPage(
  tags$head(
    tags$script(src = "https://3Dmol.org/build/3Dmol-min.js")
  ),

  tags$style(HTML("
  #toolbar {
    margin: 10px 0;
    position: relative !important;
    z-index: 10;
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
")),

  titlePanel("ciezka praca"),

  sidebarLayout(
    sidebarPanel(
      fileInput("structureFile", "Upload a PDB/mmCIF file", accept = c(".cif", ".mmcif", ".pdb"))
    ),

    mainPanel(
      div(id = "toolbar",
          tags$button(id = "btn-screenshot", "Screenshot"),
          tags$input(id = "toggle-spin", type = "checkbox", checked = "checked"),
          tags$label(" Spin me!", `for` = "toggle-spin", style = "margin-left: 8px; font-size: 16px;")

      ),
      div(id = "viewer",
          style = "width:100%; height:600px")
    )
  ),

  tags$script(src = "additional-scripts-3dmol.js")
)

server <- function(input, output, session) {
  observeEvent(input[["structureFile"]], {
    req(input[["structureFile"]])

    color_map <- rep("red", 50)
    names(color_map) <- 1L:50

    session$sendCustomMessage("renderStructure",
                              list(data = paste0(readLines(input[["structureFile"]][["datapath"]]), collapse = "\n"),
                                   colorMap = as.list(color_map),
                                   protName = tools::file_path_sans_ext(input[["structureFile"]][["name"]])
                                   ))
  })
}

shinyApp(ui, server)
