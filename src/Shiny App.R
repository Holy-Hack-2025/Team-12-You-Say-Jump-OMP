library(shiny)
library(dplyr)
library(DT)
library(ggplot2)

# Generate data
set.seed(1234)

supplier <- c("EuroPlast GmbH", "Nordic Polymers AB", "EcoMold Solutions", "PlastiTech Italia", "GreenForm Plastics")
manufacturer <- c("PolyTech Europe", "EcoPlast Industries", "Nordic Molding Solutions", "PlastiForm GmbH", "GreenPolymers Ltd.")
transport <- c("EuroLogistics Ltd.", "Nordic Freight Solutions", "EcoTrans Europe", "SwiftCargo GmbH", "GreenHaul Transport")

# Create separate dataframes for each category
suppliers <- data.frame(
  market_players = supplier,
  price_means = runif(5, min = 30, max = 70),
  price_sd = runif(5, min = 1, max = 15),
  reliability_means = runif(5, min = 30, max = 70),
  reliability_sd = runif(5, min = 1, max = 15),
  sustainability_means = runif(5, min = 30, max = 70),
  sustainability_sd = runif(5, min = 1, max = 15)
)

manufacturers <- data.frame(
  market_players = manufacturer,
  price_means = runif(5, min = 30, max = 70),
  price_sd = runif(5, min = 1, max = 15),
  reliability_means = runif(5, min = 30, max = 70),
  reliability_sd = runif(5, min = 1, max = 15),
  sustainability_means = runif(5, min = 30, max = 70),
  sustainability_sd = runif(5, min = 1, max = 15)
)

transports <- data.frame(
  market_players = transport,
  price_means = runif(5, min = 30, max = 70),
  price_sd = runif(5, min = 1, max = 15),
  reliability_means = runif(5, min = 30, max = 70),
  reliability_sd = runif(5, min = 1, max = 15),
  sustainability_means = runif(5, min = 30, max = 70),
  sustainability_sd = runif(5, min = 1, max = 15)
)

# Combined dataframe for reference
df <- rbind(suppliers, manufacturers, transports)

normalize_weights <- function(weights) {
  return(weights / sum(weights))
}

ui <- fluidPage(
  titlePanel("Supply Chain Optimization"),
  sidebarLayout(
    sidebarPanel(
      h3("Supplier Weights"),
      sliderInput("weight_s_price", "Price", min = 0, max = 1, value = 0.3, step = 0.01),
      sliderInput("weight_s_reliability", "Reliability", min = 0, max = 1, value = 0.3, step = 0.01),
      sliderInput("weight_s_sustainability", "Sustainability", min = 0, max = 1, value = 0.4, step = 0.01),
      hr(),
      
      h3("Manufacturer Weights"),
      sliderInput("weight_m_price", "Price", min = 0, max = 1, value = 0.3, step = 0.01),
      sliderInput("weight_m_reliability", "Reliability", min = 0, max = 1, value = 0.3, step = 0.01),
      sliderInput("weight_m_sustainability", "Sustainability", min = 0, max = 1, value = 0.4, step = 0.01),
      hr(),
      
      h3("Transport Weights"),
      sliderInput("weight_t_price", "Price", min = 0, max = 1, value = 0.3, step = 0.01),
      sliderInput("weight_t_reliability", "Reliability", min = 0, max = 1, value = 0.3, step = 0.01),
      sliderInput("weight_t_sustainability", "Sustainability", min = 0, max = 1, value = 0.4, step = 0.01),
      
      actionButton("update", "Update Scores"),
      hr(),
      
      # Graph display options
      h3("Graph Options"),
      checkboxInput("show_top5", "Show Top 5 Combinations", value = TRUE),
      uiOutput("combo_selector"),
      actionButton("add_combo", "Add to Graph"),
      actionButton("reset_graph", "Reset to Top 5")
    ),
    mainPanel(
      plotOutput("density_plot"),
      DTOutput("results_table")
    )
  )
)

server <- function(input, output, session) {
  # Reactive value to store which combinations to display
  selected_combos <- reactiveVal(c())
  
  observe({
    weights_s <- normalize_weights(c(input$weight_s_price, input$weight_s_reliability, input$weight_s_sustainability))
    weights_m <- normalize_weights(c(input$weight_m_price, input$weight_m_reliability, input$weight_m_sustainability))
    weights_t <- normalize_weights(c(input$weight_t_price, input$weight_t_reliability, input$weight_t_sustainability))
    
    updateSliderInput(session, "weight_s_price", value = weights_s[1])
    updateSliderInput(session, "weight_s_reliability", value = weights_s[2])
    updateSliderInput(session, "weight_s_sustainability", value = weights_s[3])
    
    updateSliderInput(session, "weight_m_price", value = weights_m[1])
    updateSliderInput(session, "weight_m_reliability", value = weights_m[2])
    updateSliderInput(session, "weight_m_sustainability", value = weights_m[3])
    
    updateSliderInput(session, "weight_t_price", value = weights_t[1])
    updateSliderInput(session, "weight_t_reliability", value = weights_t[2])
    updateSliderInput(session, "weight_t_sustainability", value = weights_t[3])
  })
  
  results <- eventReactive(input$update, {
    weights_s <- normalize_weights(c(input$weight_s_price, input$weight_s_reliability, input$weight_s_sustainability))
    weights_m <- normalize_weights(c(input$weight_m_price, input$weight_m_reliability, input$weight_m_sustainability))
    weights_t <- normalize_weights(c(input$weight_t_price, input$weight_t_reliability, input$weight_t_sustainability))
    
    combo <- c()
    score <- c()
    combo_means <- c()
    combo_sd <- c()
    
    for(i in 1:5){
      for(j in 1:5){
        for(k in 1:5){
          supplier_total_means <- c(suppliers[i,2], suppliers[i,4], suppliers[i,6]) %*% weights_s
          supplier_total_sd <- (c(suppliers[i,3]^2, suppliers[i,5]^2, suppliers[i,7]^2) %*% weights_s^2)^(1/2)
          
          manufacturer_total_means <- c(manufacturers[j,2], manufacturers[j,4], manufacturers[j,6]) %*% weights_m
          manufacturer_total_sd <- (c(manufacturers[j,3]^2, manufacturers[j,5]^2, manufacturers[j,7]^2) %*% weights_m^2)^(1/2)
          
          transport_total_means <- c(transports[k,2], transports[k,4], transports[k,6]) %*% weights_t
          transport_total_sd <- (c(transports[k,3]^2, transports[k,5]^2, transports[k,7]^2) %*% weights_t^2)^(1/2)
          
          means <- (supplier_total_means + manufacturer_total_means + transport_total_means)
          sds <- c(supplier_total_sd^2 + manufacturer_total_sd^2 + transport_total_sd^2)^(1/2)
          
          rv <- rnorm(1000, mean = means, sd = sds)
          combo <- c(combo, paste(suppliers[i,1], manufacturers[j,1], transports[k,1], sep=", "))
          score <- c(score, mean(rv) + sd(rv)^2)  # Score includes variance premium
          combo_means <- c(combo_means,  mean(rv))
          combo_sd <- c(combo_sd, sd(rv))
        }
      }
    }
    
    results <- data.frame(combo, score=round(score,2), combo_means=round(combo_means,2), combo_sd=round(combo_sd,2)) %>% arrange(score)
    
    # Reset selected combos when scores are updated
    selected_combos(c())
    
    return(results)
  })
  
  # Generate dropdown with all combinations excluding those already selected
  output$combo_selector <- renderUI({
    req(results())
    
    current_selections <- selected_combos()
    available_combos <- setdiff(results()$combo, current_selections)
    
    selectInput("combo_to_add", "Add combination to graph:", 
                choices = available_combos,
                selected = NULL)
  })
  
  # Add selected combo to the graph when button is clicked
  observeEvent(input$add_combo, {
    req(input$combo_to_add)
    current <- selected_combos()
    selected_combos(c(current, input$combo_to_add))
  })
  
  # Reset to default (empty selection, will trigger top 5 display)
  observeEvent(input$reset_graph, {
    selected_combos(c())
  })
  
  # Reset selections when results are updated
  observeEvent(input$update, {
    selected_combos(c())
  })
  
  output$results_table <- renderDT({
    datatable(results(), options = list(pageLength = 5, autoWidth = TRUE, searchable = TRUE))
  })
  
  output$density_plot <- renderPlot({
    req(results())
    
    # Get user-selected combinations
    user_selections <- selected_combos()
    
    # If show_top5 is checked or no selections are made, include top 5
    display_combos <- c()
    if(input$show_top5 || length(user_selections) == 0) {
      top5 <- results()$combo[1:5]
      display_combos <- c(display_combos, top5)
    }
    
    # Add user selections
    display_combos <- c(display_combos, user_selections)
    
    # Remove duplicates
    display_combos <- unique(display_combos)
    
    # Filter for only combinations to display
    plot_data <- results() %>%
      filter(combo %in% display_combos)
    
    # Extract means and standard deviations
    means <- plot_data$combo_means
    sds <- plot_data$combo_sd
    
    # Define x-axis range
    x_vals <- seq(min(means) - 3*max(sds), max(means) + 3*max(sds), length.out = 300)
    
    # Define color palette with enough colors
    colors <- c('red', 'blue', 'green', 'purple', 'orange', 
                'cyan', 'magenta', 'yellow', 'brown', 'pink',
                'darkgreen', 'navy', 'coral', 'teal', 'violet',
                'gold', 'darkred', 'skyblue', 'limegreen', 'darkgray')
    
    # Create density data
    density_data <- data.frame()
    
    for(i in 1:nrow(plot_data)) {
      temp_data <- data.frame(
        x = x_vals,
        density = dnorm(x_vals, mean = means[i], sd = sds[i]),
        group = plot_data$combo[i]
      )
      density_data <- rbind(density_data, temp_data)
    }
    
    # Mark top 5 in the legend if showing both top 5 and custom selections
    if(input$show_top5 && length(user_selections) > 0) {
      # Add label to top 5
      top5 <- results()$combo[1:5]
      for(i in 1:5) {
        if(i <= length(top5)) {
          density_data$group[density_data$group == top5[i]] <- paste0(top5[i], " (Top ", i, ")")
        }
      }
    }
    
    ggplot(density_data, aes(x = x, y = density, color = group)) +
      geom_line(size = 1) +  
      scale_color_manual(values = colors[1:nrow(plot_data)]) + 
      theme_minimal() +
      theme(legend.position = "bottom",
            legend.text = element_text(size = 8)) +
      guides(color = guide_legend(ncol = 1)) +
      labs(title = paste0("Density Plot of ", 
                          ifelse(input$show_top5, "Top 5", ""), 
                          ifelse(input$show_top5 && length(user_selections) > 0, " and ", ""),
                          ifelse(length(user_selections) > 0, "Selected", ""),
                          " Combinations"),
           x = "Mean Score",
           y = "Density",
           color = "Combination")
  })
}

shinyApp(ui = ui, server = server)