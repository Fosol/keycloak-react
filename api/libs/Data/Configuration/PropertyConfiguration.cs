using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Data.Entities;

namespace Data.Configurations
{
    /// <summary>
    /// PropertyConfiguration class, provides a way to configure properties in the database.
    ///</summary>
    public class PropertyConfiguration : IEntityTypeConfiguration<Property>
    {
        #region Methods
        public virtual void Configure(EntityTypeBuilder<Property> builder)
        {
            builder.ToTable("Properties");

            builder.HasKey(m => m.Id);

            builder.Property(m => m.Id).ValueGeneratedOnAdd();
            builder.Property(m => m.Address).HasMaxLength(250);
            builder.Property(m => m.Owner).HasMaxLength(250);
            builder.Property(m => m.Zoning).HasMaxLength(100);
            builder.Property(m => m.LegalName).HasMaxLength(250);
        }
        #endregion
    }
}
