

library(rsvg)

svg_to_png <- function (){
  
  svg_directory <- "./output/svg/"
  
  png_directory <- "./output/png/"
  
  pdf_directory <- "./output/pdf/"
  
  svg_files <- list.files(svg_directory,
                          pattern = "\\.svg$",
                          full.names = TRUE)
  
  
  
  svg_file = 1
  for(svg_file in svg_files){
    
    png_file <- sub(svg_directory, png_directory, svg_file)
    png_file <- sub("\\.svg$", ".png", png_file)
    rsvg::rsvg_png(svg_file, file = png_file)
    
    png_file <- sub(svg_directory, pdf_directory, svg_file)
    pdf_file <- sub("\\.svg$", ".pdf", png_file)
    rsvg::rsvg_pdf(svg_file, file = pdf_file)
  }
  }

svg_to_png()



