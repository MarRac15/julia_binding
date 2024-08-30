
public class Animal {
    public String species;
    public int age;
    public boolean endangered;

    public Animal(String species, int age, boolean endangered)
    {
        this.species = species;
        this.age = age;
        this.endangered = endangered;
    }

    public String getSpecies(){
        return species;
    }

    public int getAge(){
        return age;
    }

    public boolean  isInCage(){
        if ("tiger".equals(this.getSpecies())){
            return true;
        }
        else{
            return false;
        }
    }

    
}

