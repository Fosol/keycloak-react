namespace Data.Entities
{
    public class Property
    {
        #region Properties
        public int Id { get; set; }
        public double Latitude { get; set; }
        public double Longitude { get; set; }
        public string Address { get; set; }
        public string Owner { get; set; }
        public string LegalName { get; set; }
        public string Zoning { get; set; }
        public decimal AnnualTax { get; set; }
        public string Polygon { get; set; }
        public double LandArea { get; set; }
        #endregion
    }
}
