output "subnet_ids" {
  value = merge(
    {
      for k, s in azurerm_subnet.public :
      k => s.id
    },
    {
      for k, s in azurerm_subnet.private :
      k => s.id
    }
  )
}
