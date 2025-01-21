
library(data.table)
library(tidyverse)
library(ggplot2)
library(DiagrammeR)
library(DiagrammeRsvg)
library(magrittr)
library(rsvg)

################################################################################

pharmo <- fread("./1-pharmo/7_output/flowchart.csv")
cprd <- readRDS("./2-cprd/7_output/flowchart.rds")

################################################################################

pharmo <- pharmo %>% 
  mutate(lost = lag(n_patid) - n_patid)

cprd <- cprd %>% 
  mutate(lost = lag(n_patid) - n_patid)

################################################################################

graph2 <- grViz("
digraph cohort_flow_chart {

  # Graph style
  graph [rankdir = TB]  # Top to bottom direction

  # Node style
  node [fontname = Helvetica, 
  fontsize = 14, 
  fillcolor = '#d8efeb', 
  style = filled, 
  shape = box, 
  width = 3,
  height = 0.8]

  # Cohort 1 nodes
  aa0[label = '', style = invis, width = 4]
  aa1[label = 'PHARMO-NL', fillcolor ='#ffffff', fontname='Helvetica-Bold']
  ab1[label = 'CPRD-UK', fillcolor ='#ffffff',fontname='Helvetica-Bold']

  # Cohort 1 nodes
  a1[label = 'n = 920,525']
  e1[label = 'n = 869,577', fillcolor = '#00008B33', fontname='Helvetica-Bold']

  # Exclusion reasons for Cohort 1
  b2[label = 'n = 2', width = 2, fillcolor = '#FF000033', style = filled]
  c2[label = 'n = 49,114', width = 2, fillcolor = '#FF000033', style = filled]
  d2[label = 'n = 1,832', width = 2, fillcolor = '#FF000033', style = filled]

  # Cohort 2 nodes

  a3[label = 'n = 4,991,015']
  e3[label = 'n = 3,999,541', fillcolor = '#00008B33', fontname='Helvetica-Bold']

  # Exclusion reasons for Cohort 2
  b4[label = 'n = 307,682', width = 2, fillcolor = '#FF000033', style = filled]
  c4[label = 'n = 660,404', width = 2, fillcolor = '#FF000033', style = filled]
  d4[label = 'n = 23,388', width = 2, fillcolor = '#FF000033', style = filled]

  # Define empty nodes (invisible for alignment)
  b1 [label = '', style = invis, width = 0.01, height = 0.01]
  c1 [label = '', style = invis, width = 0.01, height = 0.01]
  d1 [label = '', style = invis, width = 0.01, height = 0.01]
  b3 [label = '', style = invis, width = 0.01, height = 0.01]
  c3 [label = '', style = invis, width = 0.01, height = 0.01]
  d3 [label = '', style = invis, width = 0.01, height = 0.01]

  # Edges for Cohort 1
  a1 -> b1 -> c1 -> d1 [dir = none]
  d1-> e1
  b1 -> b2
  c1 -> c2
  d1 -> d2

  # Edges for Cohort 2
  a3 -> b3 -> c3 -> d3 [dir = none]
  d3 -> e3
  b3 -> b4
  c3 -> c4
  d3 -> d4

  # Add description blocks (left side) for each step
  desc1 [label='Antibiotic users in the study period', 
        width = 3.5, fillcolor = '#FFFFFF']
  
  desc2 [label='Missing information about age or sex', 
        width = 3.5, fillcolor = '#FFFFFF']
        
  desc3 [label='Insufficient look-back window\n (>365 days)', 
        width = 3.5, fillcolor = '#FFFFFF']
  
  desc4 [label='Incident use not captured\n (>30 days of antibiotic-free period)', 
        width = 3.5, fillcolor = '#FFFFFF']
  
  desc5 [label='Included patients', 
        width = 3.5, fillcolor = '#FFFFFF']

  # Invisible edges for alignment
  # desc1 -> a1 [style = invis]
  # desc2 -> b1 [style = invis]
  # desc3 -> c1 [style = invis]
  # desc4 -> d1 [style = invis]
  # desc5 -> e1 [style = invis]


  aa0 -> ab1 [style = invis]
  aa0 -> desc1 -> desc2 -> desc3 -> desc4 -> desc5[style = invis]
  ab1 -> a3 [style = invis]
  aa1 -> a1 [style = invis]

  # Align descriptions
  # Define the same rank for exclusions and cohorts
  { rank = same; aa0; aa1; ab1 }
  { rank = same; desc1; a1; a3 }
  { rank = same; desc1; a1; a3 }
  { rank = same; desc2; b1; b2; b3; b4 }
  { rank = same; desc3; c1; c2; c3; c4 }
  { rank = same; desc4; d1; d2; d3; d4 }
  { rank = same; desc5; e1; e3;}
}
")

graph2

################################################################################

graph2_svg <- export_svg(graph2)

# Save the SVG file
write(graph2_svg, 
      file = "./output/svg/m_fig2_flowchart.svg")

source("./functions/svg_to_png.R")
