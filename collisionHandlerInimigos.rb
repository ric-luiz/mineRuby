#Classe de manipulação de colisões para os Inimigos
class CollisionHandlerInimigos
  def begin(a, b, arbiter)
      if a.object.atacando
        b.object.atacado = true
      end
  end
end
