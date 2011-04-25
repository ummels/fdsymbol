{
    for (i = 1; i < NF; i++)
        if ($i == "input")
        {
            filename = $(i+1)
            sub(".mf;", ";", filename)
            sub(";", ".mf", filename) 
            printf("%s ", filename)
        }
}
