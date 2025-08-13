for file in test7/*; do
    new_name=$(echo "$file" | tr '[:upper:]' '[:lower:]')
    if [ "$file" != "$new_name" ]; then
        mv -- "$file" "$new_name"
    fi
done
