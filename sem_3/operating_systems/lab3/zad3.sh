#!/bin/bash

# 1. Pobranie obrazu kota z The Cat API,
# wyodrębnienie linku do obrazu za pomocą jq,
# pobranie obrazu do pliku lokalnego
# i wyświetlenie obrazu przy użyciu catimg
cat_response=$(curl -s "https://api.thecatapi.com/v1/images/search")
cat_image_url=$(echo $cat_response | jq -r '.[0].url')
curl -s -o /tmp/cat_image.jpg "$cat_image_url"
catimg /tmp/cat_image.jpg

# 2. Pobranie losowego cytatu z Chuck Norris API,
# wyodrębnienie tekstu cytatu za pomocą jq i wyświetlenie
chuck_response=$(curl -s "https://api.chucknorris.io/jokes/random")
chuck_quote=$(echo $chuck_response | jq -r '.value')
echo "$chuck_quote"

