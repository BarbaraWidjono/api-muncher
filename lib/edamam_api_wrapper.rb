require 'httparty'

# https://api.edamam.com/search?q=chicken&app_id=05485fbf&app_key=7c36d5a80f584cf96980d40f9dbdafa4
class EdamamApiWrapper
  BASE_URL = "https://api.edamam.com/search?"
  APP_ID = ENV["APP_ID"]
  APP_KEY = ENV["APP_KEY"]


  # Rails Console Test: EdamamApiWrapper.find_recipe("chicken")
  def self.find_recipes(search_term)
    base_url = "#{BASE_URL}" + "q=#{search_term}" + "&" + "app_id=#{APP_ID}" + "&" + "app_key=#{APP_KEY}"
    encoded_url = URI.encode(base_url)
    response = HTTParty.get(encoded_url)

    recipe_list = []
    if response
      index = 0
      while index < response["hits"].length do
        single_recipe = response["hits"][index]["recipe"]
        recipe_list << create_recipe(single_recipe)
        index += 1
      end
      return recipe_list

    else
      return nil
    end

  end

  # x["hits"][0]["recipe"]["label"]
  def self.create_recipe(recipe)
    input_hash = {}
    input_hash[:label] = recipe["label"]
    input_hash[:image] = recipe["image"]
    input_hash[:url] = recipe["url"]

    input_hash[:id] = parse_recipe_id(recipe["uri"])
    input_hash[:dietLabels] = recipe["dietLabels"]
    input_hash[:healthLabels] = recipe["healthLabels"]
    input_hash[:ingredientLines] = recipe["ingredientLines"]
    return Recipe.new(input_hash)
  end

  #https://api.edamam.com/search?r=http%3A%2F%2Fwww.edamam.com%2Fontologies%2Fedamam.owl%23recipe_7bf4a371c6884d809682a72808da7dc2&app_id=05485fbf&app_key=7c36d5a80f584cf96980d40f9dbdafa4
  def self.find_specific_recipe(recipe_id)
    base = "https://api.edamam.com/search?r=http%3A%2F%2Fwww.edamam.com%2Fontologies%2Fedamam.owl%23"
    id = recipe_id
    base_url = "#{base}" + "#{id}" + "&app_id=#{APP_ID}" + "&app_key=#{APP_KEY}"
# binding.pry
    # encoded_url = URI.encode(base_url)
# binding.pry
    response = HTTParty.get(base_url)
    parsed_response = response[0]
    recipe = create_recipe(parsed_response)
# binding.pry
    # recipe = create_recipe(response)
    return recipe
  end

  #http://www.edamam.com/ontologies/edamam.owl#recipe_b79327d05b8e5b838ad6cfd9576b30b6
  def self.parse_recipe_id(unparsed_uri)
    unparsed = unparsed_uri
    location_of_ampersant = unparsed.index("#")
    id_start = location_of_ampersant + 1
    end_of_id = unparsed.length
    recipe_id = unparsed.slice(id_start...end_of_id)
    return recipe_id
  end
end
