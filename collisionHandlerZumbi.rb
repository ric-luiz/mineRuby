#Classe de manipulação de colisões para o zumbi
class CollisionHandlerZumbi
  def begin(a, b, arbiter)
      if a.object.atacando
        b.object.atacado = true
      end
  end
end
