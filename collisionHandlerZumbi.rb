#Classe de manipulação de colisões para o zumbi
class CollisionHandlerZumbi
  def begin(a, b, arbiter)
      b.object.atacado = true
  end
end
