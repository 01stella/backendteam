from django.db import models

class Category(models.Model):
    name = models.CharField(max_length=100)

    class Meta:
        managed = False
        db_table = 'category'
        verbose_name_plural = 'Categories'

    def __str__(self):
        return self.name


class Customer(models.Model):
    full_name = models.CharField(max_length=255)
    phone_number = models.CharField(max_length=20, blank=True, null=True)
    email = models.CharField(unique=True, max_length=255)
    birthday = models.DateField(blank=True, null=True)
    hashed_password = models.CharField(max_length=255)
    created_at = models.DateTimeField(blank=True, null=True)
    modified_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'customer'

    def __str__(self):
        return self.full_name


class Menu(models.Model):
    category = models.ForeignKey(Category, models.DO_NOTHING)
    item_name = models.CharField(max_length=100)
    description = models.CharField(max_length=255)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    image_url = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'menu'
        verbose_name_plural = 'Menu Items'

    def __str__(self):
        return self.item_name


class Orders(models.Model):
    customer = models.ForeignKey(Customer, models.DO_NOTHING, blank=True, null=True)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    order_status = models.CharField(max_length=50, blank=True, null=True)
    created_at = models.DateTimeField(blank=True, null=True)
    modified_at = models.DateTimeField()

    class Meta:
        managed = False
        db_table = 'orders'
        verbose_name_plural = 'Orders'

    def __str__(self):
        return f"Order #{self.id} - {self.order_status}"


class OrderItems(models.Model):
    order = models.ForeignKey(Orders, models.DO_NOTHING)
    menu = models.ForeignKey(Menu, models.DO_NOTHING)
    quantity = models.IntegerField()
    ice_level = models.CharField(max_length=20, blank=True, null=True)
    sugar_level = models.CharField(max_length=20, blank=True, null=True)
    coffee_strength = models.CharField(max_length=20, blank=True, null=True)
    item_price = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'order_items'
        verbose_name_plural = 'Order Items'

    def __str__(self):
        return f"{self.quantity}x {self.menu.item_name}"