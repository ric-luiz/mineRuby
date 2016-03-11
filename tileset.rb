#Seletor de frames para os personagens
class Tileset
      #Recupera os Dados do map.json(ou qualquer outro json) e cria uma imagem com o nome contido nele
      def initialize(json)
            @json = JSON.parse(File.read(json))
            @main_image = Gosu::Image.new(@json['meta']['image'])
      end

      #Define qual frame será renderizado
      def frame(posicao)
          f = @json['frames'][posicao]['frame']          
          @main_image.subimage(
          f['x'], f['y'], f['w'], f['h'])
      end
end
