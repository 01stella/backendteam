from django.contrib import admin
from django.db.models import Sum, Count
from .models import Category, Customer, Menu, Orders, OrderItems, Bundle, BundleItem, Stamp

# 1. Define the Custom Admin Site
class CafeAdminSite(admin.AdminSite):
    def index(self, request, extra_context=None):
        extra_context = extra_context or {}
        # Calculate totals from your DB
        extra_context['total_sales'] = Orders.objects.aggregate(total=Sum('total'))['total'] or 0
        extra_context['total_orders'] = Orders.objects.count()
        extra_context['total_customers'] = Customer.objects.count()
        return super().index(request, extra_context=extra_context)

admin_site = CafeAdminSite(name='cafe_admin')

# 2. Define your Admin Classes
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('id', 'name')
    search_fields = ('name',)

class MenuAdmin(admin.ModelAdmin):
    list_display = ('item_name', 'category', 'price', 'image_url')
    search_fields = ('item_name', 'description')
    list_filter = ('category',)
    ordering = ('category', 'item_name')

class BundleItemInline(admin.TabularInline):
    model = BundleItem
    extra = 2

class BundleAdmin(admin.ModelAdmin):
    list_display = ('name', 'price', 'image_url')
    search_fields = ('name',)
    inlines = [BundleItemInline]

class CustomerAdmin(admin.ModelAdmin):
    list_display = ('full_name', 'email', 'phone_number', 'created_at')
    search_fields = ('full_name', 'email', 'phone_number')
    date_hierarchy = 'created_at'

class OrderItemsInline(admin.TabularInline):
    model = OrderItems
    extra = 0
    readonly_fields = ('menu', 'quantity', 'ice_level', 'sugar_level', 'coffee_strength', 'item_price')
    can_delete = True

class OrdersAdmin(admin.ModelAdmin):
    list_display = ('id', 'customer', 'total', 'order_status', 'payment_method', 'payment_status', 'fulfillment_type', 'created_at')
    list_filter = ('order_status', 'payment_method', 'payment_status', 'fulfillment_type', 'created_at')
    search_fields = ('id', 'customer__full_name')
    readonly_fields = ('created_at', 'modified_at')
    inlines = [OrderItemsInline]

class StampAdmin(admin.ModelAdmin):
    list_display = ('id', 'customer', 'order', 'stamp_change', 'description', 'created_at')
    list_filter = ('stamp_change', 'created_at')
    search_fields = ('customer__full_name', 'description', 'order__id')
    readonly_fields = ('created_at',)

# 3. Register everything to the NEW cafe_admin_site
admin_site.register(Category, CategoryAdmin)
admin_site.register(Menu, MenuAdmin)
admin_site.register(Bundle, BundleAdmin)
admin_site.register(Customer, CustomerAdmin)
admin_site.register(Orders, OrdersAdmin)
admin_site.register(Stamp, StampAdmin)