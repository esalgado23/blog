class PokemonsController < ApplicationController
    before_action :set_pokemon, only: [:capture, :destroy]

    # GET /pokemons
    def index
        @pokemons = Pokemon.all
        @pokemons = @pokemons.where("name LIKE ? OR type LIKE ?", "%#{params[:name]}%", "%#{params[:type]}%") if params[:name].present? || params[:type].present?
        @pokemons = @pokemons.paginate(page: params[:page], per_page: 10)
        
        @pokemons = @pokemons.map do |pokemon|
          {
            name: pokemon.name,
            type: pokemon.type,
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

    # POST /pokemons/import
    # Asumiendo que nuestra base de datos esta en MSQLServer
    require 'tiny_tds'
    def import
      client = TinyTds::Client.new username: 'sa', password: 'LunesDeCE', host: '198.10.20.30.', database: 'pokemon_db'
    
      result = client.execute("SELECT TOP 150 * FROM pokemons")
    
      result.each do |row|
        Pokemon.create(name: row['name'], type: row['type'], captured: false, image: row['image'], capture_date: nil)
      end
    
      client.close
    end
    private

    def set_pokemon
        @pokemon = Pokemon.find(params[:id])
    end
end