
import java.util.ArrayList;

public class Zoo{
    public ArrayList<Animal> animals;
    public  int numberOf;

    public Zoo()
    {
        this.animals = new ArrayList<>();
        this.numberOf = 0;
    }

    public void addToZoo(Animal animal)
    {
        if (numberOf<10)
        {
            animals.add(animal);
            numberOf++;
        }
    }

    public ArrayList<Animal> getAnimals()
    {
        return animals;
    }

    public int getNumberOfAnimals()
    {
        return numberOf;
    }

    public Animal getFirstAnimal()
    {
        return animals.get(0);
    }

}