library(shiny)
library(ggplot2)
library(dplyr)
library(DT)
library(plotly)

hasil <- readRDS("hasil_clustering.rds")

data_raw <- hasil$data_raw
data_num <- hasil$data_num
label_count <- hasil$label_count
pca_2d <- hasil$pca_2d
pca_loading <- hasil$pca_loading
sil_values <- hasil$sil_values
summary_table <- hasil$summary_table
cluster_info <- hasil$cluster_info
n_clusters_db <- hasil$n_clusters_db
n_noise <- hasil$n_noise

num_vars <- c("Age", "Height", "Weight", "FCVC", "NCP", "CH2O", "FAF", "TUE")
jumlah_numerik <- length(num_vars)
jumlah_kategorik <- ncol(data_raw) - jumlah_numerik
# 6. UI
ui <- fluidPage(
  tags$head(
    tags$style(HTML("
      body { background-color: #ecf0f5; }
      .main-title {
        text-align: center;
        font-size: 24px;
        font-weight: bold;
        margin-top: 18px;
        color: #2c3e50;
      }
      .subtitle {
        text-align: center;
        font-size: 17px;
        margin-bottom: 18px;
        color: #34495e;
      }
      .nav-tabs {
        display: flex;
        justify-content: center;
        font-size: 16px;
        font-weight: 600;
      }
      .box-custom {
        background: white;
        padding: 18px;
        border-radius: 8px;
        margin-bottom: 18px;
        border-top: 3px solid #3c8dbc;
        box-shadow: 0 1px 4px rgba(0,0,0,0.12);
      }
      .metric-box {
        background: #3c8dbc;
        color: white;
        padding: 15px;
        border-radius: 8px;
        text-align: center;
        margin-bottom: 12px;
      }
      .metric-box h2 {
        margin: 5px 0;
        font-weight: bold;
      }
      .metric-box p {
        margin: 0;
        font-size: 14px;
      }"))),
  
  div(class = "main-title",
      "Analisis Clustering Tingkat Obesitas Berdasarkan Kebiasaan Makan dan Kondisi Fisik"),
  div(class = "subtitle",
      "Disusun oleh: Cantika Latifatul Nur Ella (24031554023)"),
  
  tabsetPanel(
    type = "tabs",
    
    tabPanel(
      "Ringkasan Data",
      
      fluidRow(
        column(
          8,
          div(class = "box-custom",
              h3("Deskripsi Dataset"),
              p("Dataset yang digunakan adalah Estimation of Obesity Levels Based On Eating Habits and Physical Condition."),
              p("Dataset ini berisi data kebiasaan makan dan kondisi fisik individu yang digunakan untuk menganalisis pola tingkat obesitas."),
              p(strong("Sumber dataset:"), 
                tags$a(
                  href = "https://archive.ics.uci.edu/dataset/544/estimation+of+obesity+levels+based+on+eating+habits+and+physical+condition",
                  "UCI Machine Learning Repository",
                  target = "_blank"
                )),
              p(strong("DOI Dataset:"), 
                tags$a(
                  href = "https://doi.org/10.24432/C5H31Z",
                  "https://doi.org/10.24432/C5H31Z",
                  target = "_blank")))),
        column(
          4,
          div(class = "metric-box", h2(nrow(data_raw)), p("Jumlah Data")),
          div(class = "metric-box", h2(ncol(data_raw)), p("Jumlah Kolom")),
          div(class = "metric-box", h2(jumlah_numerik), p("Variabel Numerik")),
          div(class = "metric-box", h2(jumlah_kategorik), p("Variabel Kategorik")))),
      
      div(class = "box-custom",
          h3("Distribusi Label Asli Tingkat Obesitas"),
          plotlyOutput("label_plot")),
      
      div(class = "box-custom",
          h3("Statistik Deskriptif"),
          DTOutput("summary_table")),
      
      fluidRow(
        column(
          5,
          div(class = "box-custom",
              h3("Loading PCA"),
              DTOutput("pca_loading"))),
        column(
          7,
          div(class = "box-custom",
              h3("Visualisasi PCA"),
              plotlyOutput("pca_plot")))),
      
      div(class = "box-custom",
          h3("Interpretasi PCA"),
          p("PC1 paling kuat dipengaruhi oleh CH2O dan FAF. Artinya, sisi kiri PC1 menggambarkan responden dengan konsumsi air dan aktivitas fisik yang lebih tinggi."),
          p("PC2 paling kuat dipengaruhi oleh TUE dan FCVC. Artinya, sisi bawah PC2 menggambarkan penggunaan teknologi yang lebih tinggi, sedangkan sisi atas menggambarkan konsumsi sayur yang lebih tinggi."))),
    
    tabPanel(
      "Clustering",
      
      fluidRow(
        column(
          4,
          div(class = "box-custom",
              h3("Pilih Metode Clustering"),
              selectInput(
                "metode",
                "Metode:",
                choices = c("K-Means", "Hierarchical", "DBSCAN", "Fuzzy C-Means", "Spectral"))),
          div(class = "box-custom",
              h3("Informasi Metode"),
              DTOutput("cluster_info"))),
        
        column(
          5,
          div(class = "box-custom",
              h3("Visualisasi Cluster"),
              plotlyOutput("cluster_plot"))),
        
        column(
          3,
          div(class = "box-custom",
              h3("Interpretasi Cluster"),
              textOutput("interpretasi"))))),
    
    tabPanel(
      "Evaluasi Clustering",
      
      fluidRow(
        column(
          7,
          div(class = "box-custom",
              h3("Grafik Perbandingan Silhouette Score"),
              plotlyOutput("sil_plot"))),
        column(
          5,
          div(class = "box-custom",
              h3("Interpretasi Evaluasi"),
              p("Berdasarkan nilai silhouette score, metode terbaik adalah Spectral Clustering dengan nilai 0,1881."),
              p("Namun, nilai silhouette seluruh metode masih tergolong rendah, sehingga pemisahan cluster belum terlalu tegas."),
              p("K-Means tetap berguna karena menghasilkan segmentasi yang lebih rinci, sedangkan DBSCAN kurang cocok sebagai metode utama karena menghasilkan banyak noise.")
          ),
          div(class = "box-custom",
              h3("Kesimpulan"),
              p("Secara umum, pola responden banyak dipengaruhi oleh konsumsi air, aktivitas fisik, penggunaan teknologi, dan konsumsi sayur. Spectral Clustering menjadi metode terbaik berdasarkan evaluasi numerik, sedangkan K-Means lebih mudah digunakan untuk interpretasi cluster.")
          ))))))

# 7. SERVER
server <- function(input, output) {
  
  output$label_plot <- renderPlotly({
    p <- ggplot(label_count, aes(x = reorder(NObeyesdad, -n), y = n, fill = NObeyesdad)) +
      geom_col() +
      geom_text(aes(label = n), vjust = -0.3, size = 3.5) +
      theme_minimal() +
      labs(
        title = "Distribusi Label Asli Tingkat Obesitas",
        x = "Kategori Obesitas",
        y = "Jumlah"
      ) +
      theme(
        legend.position = "none",
        axis.text.x = element_text(angle = 35, hjust = 1)
      )
    
    ggplotly(p)})
  
  output$missing_table <- renderDT({
    datatable(
      data.frame(
        Variabel = names(missing_values),
        Missing_Value = as.integer(missing_values)
      ),
      options = list(pageLength = 8))})
  
  output$summary_table <- renderDT({
    datatable(summary_table, options = list(pageLength = 8))})
  
  output$pca_loading <- renderDT({
    datatable(pca_loading, options = list(pageLength = 8))})
  
  output$pca_plot <- renderPlotly({
    p <- ggplot(pca_2d, aes(x = PC1, y = PC2)) +
      geom_point(alpha = 0.5, color = "#1976D2", size = 1.2) +
      theme_minimal() +
      labs(
        title = "Visualisasi PCA",
        subtitle = "PC1: CH2O & FAF | PC2: TUE & FCVC",
        x = "PC1",
        y = "PC2")
    
    ggplotly(p)})
  
  output$cluster_info <- renderDT({
    datatable(
      cluster_info[cluster_info$Metode == input$metode, ],
      options = list(dom = "t"))})
  
  output$cluster_plot <- renderPlotly({
    p <- ggplot(
      pca_2d,
      aes(
        x = PC1,
        y = PC2,
        color = .data[[input$metode]]
      )
    ) +
      geom_point(alpha = 0.5, size = 1.2) +
      theme_minimal() +
      labs(
        title = paste("Hasil", input$metode, "Clustering"),
        subtitle = "Visualisasi pada bidang PC1 dan PC2",
        x = "PC1",
        y = "PC2",
        color = "Cluster"
      )
    
    ggplotly(p)})
  
  output$interpretasi <- renderText({
    if (input$metode == "K-Means") {
      "K-Means menghasilkan 8 cluster. Cluster di sisi kiri PC1 cenderung memiliki konsumsi air dan aktivitas fisik lebih tinggi, sedangkan cluster di sisi kanan cenderung lebih rendah. Cluster bagian bawah PC2 menunjukkan penggunaan teknologi lebih tinggi."
    } else if (input$metode == "Hierarchical") {
      "Hierarchical Clustering menghasilkan 8 cluster dengan complete linkage. Polanya mirip K-Means, tetapi berdasarkan silhouette score pemisahan cluster kurang kuat."
    } else if (input$metode == "DBSCAN") {
      paste0("DBSCAN menghasilkan ", n_clusters_db, " cluster dan ", n_noise, " noise. Metode ini kurang cocok sebagai segmentasi utama, tetapi berguna untuk mendeteksi data yang tidak mengikuti pola mayoritas.")
    } else if (input$metode == "Fuzzy C-Means") {
      "Fuzzy C-Means menghasilkan 2 cluster besar. Cluster sisi kiri menunjukkan konsumsi air dan aktivitas fisik lebih baik, sedangkan sisi kanan menunjukkan pola yang lebih pasif."
    } else {
      "Spectral Clustering menghasilkan 2 cluster dan memiliki silhouette score tertinggi. Metode ini paling baik secara evaluasi numerik, meskipun pemisahan cluster masih belum terlalu tajam."
    }})
  
  output$sil_table <- renderDT({
    datatable(sil_values, options = list(dom = "t"))})
  
  output$sil_plot <- renderPlotly({
    p <- ggplot(sil_values, aes(x = Metode, y = Silhouette, fill = Metode)) +
      geom_col() +
      geom_text(aes(label = Silhouette), vjust = -0.4) +
      theme_minimal() +
      labs(
        # title = "Perbandingan Silhouette Score",
        x = "Metode",
        y = "Silhouette Score"
      ) +
      theme(legend.position = "none")
    
    ggplotly(p)})}

# 8. RUN APP
shinyApp(ui = ui, server = server)