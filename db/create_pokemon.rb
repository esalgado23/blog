class CreatePokemons < ActiveRecord::Migration[6.0]
    def change
        create_table :pokemons do |t|
            t.string :name
            t.string :type
            t.string :image
            t.boolean :captured, default: false
            t.datetime :capture_date

            t.timestamps
        end
    end
end