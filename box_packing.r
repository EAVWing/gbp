## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE)


## ------------------------------------------------------------------------
#install.packages('gbp')
library(tidyverse)
library(DomoR)
library(gbp)

## ------------------------------------------------------------------------
load("domoCustomer")
load("domoAccessToken")
init(domoCustomer, domoAccessToken)


## ------------------------------------------------------------------------
box_list <- fetch("9262878b-74f7-45c3-b0a1-037a26a6b820")
shipments <- fetch("d003b999-a0c4-40b6-8ebc-22aab825855b") %>% 
  mutate(used_box_alias = ifelse(is.na(used_box_alias), "Unknown", used_box_alias)) %>%
  filter(products_quantity > 0, 
         used_box_alias != 'NOBOX',
         products_length > 0,
         products_width > 0, 
         products_height > 0,
         products_weight > 0,
         shipments_id == 51348563)


## ------------------------------------------------------------------------
it <- data.frame(oid = integer(),
                     sku = integer(),
                     l = numeric(),
                     d = numeric(),
                     h = numeric(),
                     w = numeric())

for(i in 1:dim(shipments)[1]){
  if(shipments$products_quantity[i] == 1){
    newDF = data.frame(oid = as.integer(shipments$shipments_id[i]),
                   sku = as.integer(shipments$products_id[i]),
                   l = as.numeric(shipments$products_length[i]),
                   d = as.numeric(shipments$products_width[i]),
                   h = as.numeric(shipments$products_height[i]),
                   w = as.numeric(shipments$products_weight[i]))
    it = rbind(it, newDF)
  }
  else{
    subTable = data.frame(oid = integer(),
                   sku = integer(),
                   l = numeric(),
                   d = numeric(),
                   h = numeric(),
                   w = numeric())
    for(j in 1:shipments$products_quantity[i]){
      newDF = data.frame(oid = as.integer(shipments$shipments_id[i]),
                   sku = as.integer(shipments$products_id[i]),
                   l = as.numeric(shipments$products_length[i]),
                   d = as.numeric(shipments$products_width[i]),
                   h = as.numeric(shipments$products_height[i]),
                   w = as.numeric(shipments$products_weight[i]))
      subTable = rbind(subTable, newDF)
    }
    it = rbind(it, subTable)
  }
}

big_box <- data.frame(id = 'too_big', l = 40, d = 40, h = 10, w = 60)

bn <- box_list %>%
  select(-box_dims) %>%
  filter(!box_alias %in% c('HZ1', 'HZ2', 'PLY1', 'P1')) %>%
  rename(id = box_alias,
         l = box_length,
         d = box_width,
         h = box_height) %>%
  mutate(w = 70) %>%
  rbind(big_box) %>%
  mutate(volume = l*d*h) %>%
  arrange(volume)


## ------------------------------------------------------------------------
sn <- bpp_solver(it = it, bn = bn)


## ------------------------------------------------------------------------
bpp_viewer(sn)

