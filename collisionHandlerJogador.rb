class CollisionHandlerJogador
  def begin(a, b, arbiter)
      a.object.atacado = true
      a.object.qualLadoInimigo = b.object.qualLado
  end
end
