import csv

first_egg = "a"
second_egg = "b"
third_egg = "c"
fourth_egg = "d"
ref_suffix = "CR.tif"
query_suffix = "EH.TIF"

def get_ref_and_query_egg_name(egg_name, ref_egg, query_egg):
    ref_name_tuple = (egg_name, ref_egg, ref_suffix)
    query_name_tuple = (egg_name, query_egg, query_suffix)
    ref_egg_image_name = "_".join(ref_name_tuple)
    query_egg_image_name = "_".join(query_name_tuple)

    return ref_egg_image_name, query_egg_image_name

def get_ref_egg_name(egg_name, ref_egg):
    ref_name_tuple = (egg_name, ref_egg, ref_suffix)
    ref_egg_image_name = "_".join(ref_name_tuple)

    return ref_egg_image_name

def get_egg_name(full_egg_name):
    end_index = full_egg_name.index("_a_CR.tif")
    egg_name = full_egg_name[:end_index]

    return egg_name

first_ptsA = []
first_ptsB = []
second_ptsA = []
second_ptsB = []
third_ptsA = []
third_ptsB = []

change_egg = False
# egg_name = "2019_PS089_P1"
first_ref_egg_image_name = "2019_PS089_P1_a_CR.tif"
second_ref_egg_image_name = "2019_PS089_P1_b_CR.tif"
third_ref_egg_image_name = "2019_PS089_P1_c_CR.tif"
first_query_egg_image_name = "2019_PS089_P1_b_EH.TIF"
second_query_egg_image_name = "2019_PS089_P1_c_EH.TIF"
third_query_egg_image_name = "2019_PS089_P1_d_EH.TIF"

egg_names = []

new_pair = False

with open('matched_features.csv') as csv_file:
    csv_reader = csv.reader(csv_file, delimiter=';')
    for i, row in enumerate(csv_reader):
        ref_id = row[0]
        query_id = row[3]
        if ref_id == "ref_id":
            print("new pair of eggs")
            new_pair = True
            continue
        if new_pair:
            ref_len = len(ref_id)
            egg_name = ref_id[0:ref_len-9]
            egg_names.append(egg_name)
            new_pair = False

        #     change_egg = True
        #     continue
        # if change_egg:
        #     egg_name = get_egg_name(row[0])
        first_ref_egg_image_name, first_query_egg_image_name  = get_ref_and_query_egg_name(egg_name, first_egg, second_egg)
        second_ref_egg_image_name, second_query_egg_image_name  = get_ref_and_query_egg_name(egg_name, second_egg, third_egg)
        third_ref_egg_image_name, third_query_egg_image_name  = get_ref_and_query_egg_name(egg_name, third_egg, fourth_egg)
            # change_egg = False
        if ref_id == first_ref_egg_image_name and query_id == first_query_egg_image_name:
            first_ptsA.append((row[1], row[2]))
            first_ptsB.append((row[4], row[5]))
        if ref_id == second_ref_egg_image_name and query_id == second_query_egg_image_name:
            second_ptsA.append((row[1], row[2]))
            second_ptsB.append((row[4], row[5]))
        if ref_id == third_ref_egg_image_name and query_id == third_query_egg_image_name:
            third_ptsA.append((row[1], row[2]))
            third_ptsB.append((row[4], row[5]))


print("help")
