class Guest < Hobo::Model::Guest

  def administrator?
    false
  end

  def developer?
    false
  end
end
