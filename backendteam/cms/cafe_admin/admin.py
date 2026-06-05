from django.contrib import admin
from .models import Category, Customer, Menu, Orders, OrderItems, Bundle, BundleItem

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')
    search_fields = ('name',)

@admin.register(Menu)
class MenuAdmin(admin.ModelAdmin):
    # Creates columns in the dashboard
    list_display = ('item_name', 'category', 'price', 'image_url')
    # Adds a search bar for coffee names
    search_fields = ('item_name', 'description')
    # Adds a sidebar filter to sort by category
    list_filter = ('category',)
    ordering = ('category', 'item_name')

class BundleItemInline(admin.TabularInline):
    model = BundleItem
    extra = 2

@admin.register(Bundle)
class BundleAdmin(admin.ModelAdmin):
    list_display = ('name', 'price', 'image_url')
    search_fields = ('name',)
    inlines = [BundleItemInline]

@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ('full_name', 'email', 'phone_number', 'created_at')
    search_fields = ('full_name', 'email', 'phone_number')
    date_hierarchy = 'created_at'


# We use an "Inline" so you can see the specific coffees inside an order 
# directly on the Order page, rather than having to click around.
class OrderItemsInline(admin.TabularInline):
    model = OrderItems
    extra = 0
    readonly_fields = ('menu', 'quantity', 'ice_level', 'sugar_level', 'coffee_strength', 'item_price')
    can_delete = True

@admin.register(Orders)
class OrdersAdmin(admin.ModelAdmin):
    list_display = ('id', 'customer', 'total', 'order_status', 'created_at')
    list_filter = ('order_status', 'created_at')
    search_fields = ('id', 'customer__full_name')
    readonly_fields = ('created_at', 'modified_at')
    inlines = [OrderItemsInline]