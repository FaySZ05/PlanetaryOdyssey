library(shiny)
library(htmltools)
library(dplyr)
library(magrittr)
library(httr)
library(jsonlite)
library(bslib)
library(purrr)

# Load planet data
planets <- data.frame(
  name = c("Mercury", "Venus", "Earth", "Mars", "Jupiter", "Saturn", "Uranus", "Neptune"),
  distance = c(0.39, 0.72, 1, 1.52, 5.20, 9.54, 19.19, 30.07),  # AU
  radius = c(0.38, 0.95, 1, 0.53, 11.21, 9.45, 4.01, 3.88),  # Earth radii
  mass = c(0.055, 0.815, 1, 0.107, 317.8, 95.2, 14.5, 17.1),  # Earth masses
  temperature = c(440, 737, 288, 210, 165, 134, 76, 72),  # Kelvin
  image_url = c(
    "https://solarsystem.nasa.gov/system/stellar_items/image_files/2_feature_1600x900_mercury.jpg",
    "https://solarsystem.nasa.gov/system/stellar_items/image_files/3_feature_1600x900_venus.jpg",
    "https://solarsystem.nasa.gov/system/stellar_items/image_files/17_earth_1600x900.jpg",
    "https://solarsystem.nasa.gov/system/stellar_items/image_files/6_mars.jpg",
    "https://solarsystem.nasa.gov/system/stellar_items/image_files/16_jupiter_1600x900.jpg",
    "https://solarsystem.nasa.gov/system/stellar_items/image_files/38_saturn_1600x900.jpg",
    "https://solarsystem.nasa.gov/system/stellar_items/image_files/69_feature_1600x900_uranus_new.jpg",
    "https://solarsystem.nasa.gov/system/stellar_items/image_files/90_feature_1600x900_neptune_new.jpg"
  )
)

# Load exoplanet data (100+ options)
exoplanets <- read.csv("https://exoplanetarchive.ipac.caltech.edu/TAP/sync?query=select+pl_name,sy_dist,pl_rade,pl_bmasse,pl_eqt+from+ps+where+pl_name+is+not+null+and+sy_dist+is+not+null+and+pl_rade+is+not+null+and+pl_bmasse+is+not+null+and+pl_eqt+is+not+null+order+by+sy_dist+asc&format=csv")
names(exoplanets) <- c("name", "distance", "radius", "mass", "temperature")
exoplanets <- head(exoplanets, 100)  # Limit to 100 exoplanets for this example

ui <- navbarPage(
  title = "Planetary Explorer",
  theme = bs_theme(version = 4, bootswatch = "darkly"),
  
  header = tags$head(
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/controls/OrbitControls.min.js"),
    tags$script(src = "https://d3js.org/d3.v7.min.js"),  # Add D3.js for advanced visualizations
    tags$script("(function(w,d,s,l,i){w[l]=w[l]||[];w[l].push({'gtm.start': new Date().getTime(),event:'gtm.js'});var f=d.getElementsByTagName(s)[0], j=d.createElement(s),dl=l!='dataLayer'?'&l='+l:'';j.async=true;j.src= 'https://www.googletagmanager.com/gtm.js?id='+i+dl;f.parentNode.insertBefore(j,f); })(window,document,'script','dataLayer','GTM-K8FCG4S');"),
    tags$script(id = "_fed_an_ua_tag", src = "https://dap.digitalgov.gov/Universal-Federated-Analytics-Min.js?agency=NASA&pga4=G-THVT6S3D3X&subagency=Eyes-on-Exoplanets&yt=true&dclink=true&sp=search,s,q&sdor=false&exts=tif,tiff,webp,png", async = "", defer = ""),
    tags$style(HTML("
      #planetarium, #exoplanetarium, #constellation-creator { height: 60vh; min-height: 400px; }
      .info-section { margin-top: 20px; }
      .milky-way-image { width: 100%; height: 300px; object-fit: cover; margin-top: 20px; margin-bottom: 20px; }
      #nasa-eyes-iframe { width: 100%; height: 80vh; border: none; }
    "))
  ),
  
  tabPanel("Planets",
           fluidPage(
             div(class = "container-fluid mt-4",
                 # Solar System Scope iframe
                 HTML('<iframe src="https://www.solarsystemscope.com/iframe" width="100%" height="400" style="min-width:900px; min-height: 650px; border: 2px solid #0f5c6e;"></iframe>'),
                 
                 # Milky Way image
                 tags$img(src = "https://www.nasa.gov/sites/default/files/thumbnails/image/potw2208a.jpg", 
                          class = "milky-way-image", 
                          alt = "Milky Way Galaxy"),
                 
                 # 3D visualization
                 div(id = "planetarium", class = "w-100"),
                 
                 div(class = "row info-section",
                     div(class = "col-md-6",
                         h3("Controls"),
                         actionButton("resetPlanets", "Reset View", class = "btn btn-primary mb-2"),
                         checkboxInput("showPlanetLabels", "Show Labels", value = TRUE),
                         selectInput("selectedPlanet", "Select Planet:", 
                                     choices = planets$name,
                                     selected = planets$name[1])
                     ),
                     div(class = "col-md-6",
                         h3("Planet Information"),
                         textOutput("planetInfo"),
                         uiOutput("planetImage")
                     )
                 )
             )
           )
  ),
  
  tabPanel("Exoplanets",
           fluidPage(
             div(class = "container-fluid mt-4",
                 # NASA Eyes on Exoplanets iframe
                 tags$iframe(
                   id = "nasa-eyes-iframe",
                   src = "https://exoplanets.nasa.gov/eyes-on-exoplanets/",
                   width = "100%",
                   height = "80vh",
                   frameborder = "0"
                 ),
                 
                 # 3D visualization (optional, you can remove if not needed)
                 div(id = "exoplanetarium", class = "w-100"),
                 
                 div(class = "row info-section",
                     div(class = "col-md-6",
                         h3("Controls"),
                         actionButton("resetExoplanets", "Reset View", class = "btn btn-primary mb-2"),
                         checkboxInput("showExoplanetLabels", "Show Labels", value = TRUE),
                         selectInput("selectedExoplanet", "Select Exoplanet:", 
                                     choices = exoplanets$name,
                                     selected = exoplanets$name[1])
                     ),
                     div(class = "col-md-6",
                         h3("Exoplanet Information"),
                         textOutput("exoplanetInfo"),
                         uiOutput("exoplanetImage")
                     )
                 )
             )
           )
  ),
  
  tabPanel("Constellation Creator",
           fluidPage(
             div(class = "container-fluid mt-4",
                 div(id = "constellation-creator", class = "w-100"),
                 
                 div(class = "row info-section",
                     div(class = "col-md-4",
                         h3("Controls"),
                         actionButton("resetConstellation", "Reset View", class = "btn btn-primary mb-2"),
                         textInput("constellationName", "Constellation Name", ""),
                         actionButton("saveConstellation", "Save Constellation", class = "btn btn-success mb-2"),
                         checkboxInput("showStarNames", "Show Star Names", value = FALSE),
                         checkboxInput("showStarColors", "Show Star Colors", value = TRUE),
                         selectInput("visualOverlay", "Visual Overlay",
                                     choices = c("None", "Ecliptic", "Galactic Grid", "Equatorial Grid"),
                                     selected = "None")
                     ),
                     div(class = "col-md-4",
                         h3("Star Information"),
                         verbatimTextOutput("starInfo")
                     ),
                     div(class = "col-md-4",
                         h3("Saved Constellations"),
                         uiOutput("savedConstellations")
                     )
                 )
             )
           )
  )
)

server <- function(input, output, session) {
  output$planetInfo <- renderText({
    req(input$selectedPlanet)
    planet <- planets %>% filter(name == input$selectedPlanet)
    paste0(
      "Name: ", planet$name, "\n",
      "Distance: ", planet$distance, " AU\n",
      "Radius: ", planet$radius, " Earth radii\n",
      "Mass: ", planet$mass, " Earth masses\n",
      "Temperature: ", planet$temperature, " K"
    )
  })
  
  output$planetImage <- renderUI({
    req(input$selectedPlanet)
    planet <- planets %>% filter(name == input$selectedPlanet)
    tags$img(src = planet$image_url, width = "100%", alt = planet$name)
  })
  
  output$exoplanetInfo <- renderText({
    req(input$selectedExoplanet)
    planet <- exoplanets %>% filter(name == input$selectedExoplanet)
    paste0(
      "Name: ", planet$name, "\n",
      "Distance: ", planet$distance, " parsecs\n",
      "Radius: ", planet$radius, " Earth radii\n",
      "Mass: ", planet$mass, " Earth masses\n",
      "Temperature: ", planet$temperature, " K"
    )
  })
  
  output$exoplanetImage <- renderUI({
    req(input$selectedExoplanet)
    planet <- exoplanets %>% filter(name == input$selectedExoplanet)
    
    # Use NASA's Exoplanet Exploration API to get an artistic rendering
    api_url <- paste0("https://exoplanets.nasa.gov/api/v1/planets/", gsub(" ", "-", tolower(planet$name)))
    response <- GET(api_url)
    
    if (status_code(response) == 200) {
      data <- fromJSON(content(response, "text"))
      image_url <- paste0("https://exoplanets.nasa.gov", data$image)
    } else {
      image_url <- "https://placehold.co/600x400?text=No+Image+Available"
    }
    
    tags$img(src = image_url, width = "100%", alt = planet$name)
  })
  
  # Constellation Creator server logic
  constellations <- reactiveVal(list())
  
  observeEvent(input$saveConstellation, {
    req(input$constellationName)
    new_constellation <- list(
      name = input$constellationName,
      stars = input$selectedStars  # This will be updated by JavaScript
    )
    current <- constellations()
    current[[input$constellationName]] <- new_constellation
    constellations(current)
  })
  
  output$savedConstellations <- renderUI({
    saved <- constellations()
    if (length(saved) == 0) {
      return(p("No constellations saved yet."))
    }
    tagList(
      map(names(saved), ~actionLink(paste0("constellation_", .x), .x))
    )
  })
  
  output$starInfo <- renderText({
    req(input$selectedStar)
    # This would be replaced with actual star data
    paste("Star Name:", input$selectedStar,
          "\nColor:", sample(c("Red", "Blue", "White", "Yellow"), 1),
          "\nMagnitude:", round(runif(1, 0, 6), 2))
  })
  
  observe({
    session$sendCustomMessage("updatePlanets", planets)
  })
  
  observe({
    session$sendCustomMessage("updateExoplanets", exoplanets)
  })
  
  observeEvent(input$resetPlanets, {
    session$sendCustomMessage("resetPlanetView", TRUE)
  })
  
  observeEvent(input$resetExoplanets, {
    session$sendCustomMessage("resetExoplanetView", TRUE)
  })
  
  observe({
    session$sendCustomMessage("togglePlanetLabels", input$showPlanetLabels)
  })
  
  observe({
    session$sendCustomMessage("toggleExoplanetLabels", input$showExoplanetLabels)
  })
  
  observeEvent(input$selectedPlanet, {
    session$sendCustomMessage("focusPlanet", input$selectedPlanet)
  })
  
  observeEvent(input$selectedExoplanet, {
    session$sendCustomMessage("focusExoplanet", input$selectedExoplanet)
  })
  
  observe({
    session$sendCustomMessage("updateVisualOverlay", input$visualOverlay)
  })
  
  observe({
    session$sendCustomMessage("toggleStarNames", input$showStarNames)
  })
  
  observe({
    session$sendCustomMessage("toggleStarColors", input$showStarColors)
  })
  
  observeEvent(input$resetConstellation, {
    session$sendCustomMessage("resetConstellationView", TRUE)
  })
}

shinyApp(ui = ui, server = server)