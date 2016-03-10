class CollisionHandlerJogador
  def begin(a, b, arbiter)
      a.object.atacado = true
      a.object.qualLadoZumbi = b.object.qualLado
  end
end
