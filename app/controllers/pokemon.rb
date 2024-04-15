class PokemonsController < ApplicationController
  before_action :set_pokemon, only: [:capture, :destroy]

    # GET /pokemons
    def index
      @pokemons = Pokemon.all
      filter_query = "name LIKE ? OR pokemon_type LIKE ?"
      @pokemons = @pokemons.where(filter_query, "%#{params[:name]}%", "%#{params[:type]}%") if params[:name].present? || params[:type].present?
      @pokemons = @pokemons.paginate(page: params[:page], per_page: 10)
      @pokemons = @pokemons.map do |pokemon|
        {
          name: pokemon.name,
          pokemon_type: pokemon.pokemon_type,  # Actualizado de 'type' a 'pokemon_type'
          image: pokemon.image,
          captured: pokemon.captured
        }
      end

      render json: { pokemons: @pokemons, total_pages: @pokemons.total_pages, total_pokemons: Pokemon.count }
  end

    # PUT /pokemons/:id/capture
    def capture
        if @pokemon.captured
          render json: { error: "Pokemon already captured" }, status: :unprocessable_entity
        else
          if Pokemon.where(captured: true).count >= 6
            oldest_captured = Pokemon.where(captured: true).order(:capture_date).first
            oldest_captured.update(captured: false, capture_date: nil)
          end
          @pokemon.update(captured: true, capture_date: Time.now)
          render json: @pokemon
        end
      end

    # GET /pokemons/captured
    def captured
        @pokemons = Pokemon.where(captured: true)
        render json: @pokemons
    end

    # DELETE /pokemons/:id
    def destroy
        @pokemon.update(captured: false)
        render json: @pokemon
    end

require 'net/http'
require 'json'

  # POST /pokemons/import
  def import
    url = 'https://pokeapi.co/api/v2/pokemon?limit=150'
    begin
      pokemons_response = Net::HTTP.get(URI(url))
      pokemons_data = JSON.parse(pokemons_response)["results"]

      pokemons_data.each do |pokemon|
        pokemon_detail_response = Net::HTTP.get(URI(pokemon["url"]))
        pokemon_detail = JSON.parse(pokemon_detail_response)

        name = pokemon_detail["name"]
        image = pokemon_detail["sprites"]["versions"]["generation-v"]["black-white"]["animated"]["front_default"]
        pokemon_type = pokemon_detail["types"].map { |t| t["type"]["name"] }.join(", ")

        Pokemon.create(name: name, pokemon_type: pokemon_type, image: image, captured: false, capture_date: nil)
      end
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
end

    private

    def set_pokemon
        @pokemon = Pokemon.find(params[:id])
    end
end