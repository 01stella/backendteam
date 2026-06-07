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

class Bundle(models.Model):
    name = models.CharField(max_length=255)
    price = models.IntegerField()
    image_url = models.CharField(max_length=255, blank=True, null=True)

    class Meta:
        db_table = 'bundles' # Connects exactly to your HeidiSQL table
        managed = False # Tells Django: "Don't create this, it already exists in MySQL"

    def __str__(self):
        return self.name

class BundleItem(models.Model):
    bundle = models.ForeignKey(Bundle, on_delete=models.CASCADE)
    menu_item = models.ForeignKey('Menu', on_delete=models.CASCADE) # Links to your existing Menu model

    class Meta:
        db_table = 'bundle_items'
        managed = False

    def __str__(self):
        return f"{self.bundle.name} - {self.menu_item.item_name}"


class Orders(models.Model):
    customer = models.ForeignKey(Customer, models.DO_NOTHING, blank=True, null=True)
    total = models.DecimalField(max_digits=10, decimal_places=2)
    order_status = models.CharField(max_length=50, blank=True, null=True)
    payment_method = models.CharField(max_length=50, blank=True, null=True)
    payment_status = models.CharField(max_length=20, blank=True, null=True)
    created_at = models.DateTimeField(blank=True, null=True)
    modified_at = models.DateTimeField()
    fulfillment_type = models.CharField(max_length=20)
    pickup_time = models.TimeField(blank=True, null=True)
    delivery_floor = models.CharField(max_length=50, blank=True, null=True)
    delivery_room = models.CharField(max_length=50, blank=True, null=True)

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


class Stamp(models.Model):
    customer = models.ForeignKey(Customer, models.DO_NOTHING)
    order = models.OneToOneField(Orders, models.DO_NOTHING, blank=True, null=True)
    stamp_change = models.IntegerField()
    description = models.CharField(max_length=255, blank=True, null=True)
    created_at = models.DateTimeField(blank=True, null=True)

    class Meta:
        managed = False
        db_table = 'stamps'
        verbose_name_plural = 'Stamps'

    def __str__(self):
        return f"{self.customer.full_name}: {self.stamp_change}"
