library(shiny)

options(shiny.maxRequestSize = 30*1024^2)

ui <- fluidPage(
  tags$head(
    tags$script(src = "https://3Dmol.org/build/3Dmol-min.js")
  ),

  tags$style(HTML("
  #toolbar {
    margin: 10px;
  }
  #btn-screenshot {
    position: absolute;
    z-index: 1000;
    font-size: 16px;
    padding: 8px 12px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
  }
")),

  titlePanel("ciezka praca"),

  sidebarLayout(
    sidebarPanel(
      fileInput("structureFile", "Upload a PDB/mmCIF file", accept = c(".cif", ".mmcif", ".pdb"))
    ),

    mainPanel(
      div(id = "toolbar",
          tags$button(id = "btn-screenshot", "Screenshot")
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

    color_map <- c("10" = "red", "11" = "orange", "12" = "yellow", "18" = "red",
                   "19" = "red", "20" = "red", "21" = "red")

    color_map <- rep("red", 100)
    names(color_map) <- 1L:100

    session$sendCustomMessage("renderStructure",
                              list(data = paste0(readLines(input[["structureFile"]][["datapath"]]), collapse = "\n"),
                                   colorMap = as.list(color_map)))
  })
}

shinyApp(ui, server)
